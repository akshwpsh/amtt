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
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Product List'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
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
          )),
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
            return postName
                .toLowerCase()
                .contains(_searchText?.toLowerCase() ?? '');
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(child: Text('검색하신 내용에 맞는 상품이없어용'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final String postname = data['postName'] ?? 'No title';
              final String userName = data['userName'] ?? 'Unknown';
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
                  subtitle: Text('by $userName\n$formattedDate'),
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
