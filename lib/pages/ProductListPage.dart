import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'ProductDetailPage.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _searchText = '';
  String? _selectedCategory;
  TextEditingController _searchController = TextEditingController();

  void _selectCategory() async {
    final List<String> categories = ['전자제품', '책', '문구', '생활용품', '의류', '취미'];
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('카테고리 선택'),
          content: SingleChildScrollView(
            child: ListBody(
              children: categories.map((category) {
                return ListTile(
                  title: Text(category),
                  onTap: () {
                    Navigator.pop(context, category);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    if (selectedCategory != null) {
      setState(() {
        _selectedCategory = selectedCategory;
      });
    } else {
      setState(() {
        _selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품 목록'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "검색하세용",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _searchText = _searchController.text;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: _selectCategory,
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('products')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          final filteredDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String postName = data['postName'] ?? 'No title';
            final String category = data['category'] ?? '';

            final matchesSearchText = _searchText == null ||
                _searchText!.isEmpty ||
                postName.toLowerCase().contains(_searchText!.toLowerCase());
            final matchesCategory = _selectedCategory == null ||
                _selectedCategory!.isEmpty ||
                category == _selectedCategory;

            return matchesSearchText && matchesCategory;
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(child: Text('검색하신 내용에 맞는 상품이없어용'));
          }
          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final String postname = data['postName'] ?? 'No title';
              final String userName = data['userName'] ?? 'Unknown';
              final String category = data['category'] ?? 'No category';
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final String formattedDate =
                  DateFormat('yyyy-MM-dd').format(timestamp.toDate());
              final List<dynamic> imageUrls = data['imageUrls'] ?? [];

              return Card(
                child: ListTile(
                  leading: imageUrls.isNotEmpty
                      ? Image.network(
                          imageUrls[0],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error);
                          },
                        )
                      : null,
                  title: Text(postname),
                  subtitle: Text('by $userName\n$formattedDate\n카테고리 : $category'),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          postId: doc.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
