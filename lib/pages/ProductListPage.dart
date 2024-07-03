import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').orderBy('timestamp', descending: true).snapshots(),
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

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final String postname = data['postname'] ?? 'No title';
              final String userName = data['userName'] ?? 'Unknown';
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final String formattedDate = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
              final List<dynamic> imageUrls = data['imageUrls'] ?? [];

              return Card(
                child: ListTile(
                  leading: imageUrls.isNotEmpty
                      ? Image.network(imageUrls[0], width: 50, height: 50, fit: BoxFit.cover)
                      : null,
                  title: Text(postname),
                  subtitle: Text('by $userName\n$formattedDate'),
                  isThreeLine: true,
                  onTap: () {
                    // 게시물 상세 페이지로 이동하는 코드 추가 가능
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
