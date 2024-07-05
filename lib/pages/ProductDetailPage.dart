import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatelessWidget {
  final String postId;

  ProductDetailPage({required this.postId});

  Future<Map<String, dynamic>> fetchPostDetails(String postId) async {
    // Firestore에서 해당 postId로 데이터를 가져오는 예시입니다.
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('products').doc(postId).get();
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchPostDetails(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            Map<String, dynamic> data = snapshot.data!;
            String postName = data['postName'];
            String userName = data['userName'];
            Timestamp timestamp = data['timestamp'];
            String formattedDate = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
            String price = data['productPrice'];
            String description = data['postDescription'];
            String university = data['University'];
            List<dynamic> imageUrls = data['imageUrls'];

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrls.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              imageUrls[index],
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 16.0),
                  Text(
                    postName,
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text('by $userName'),
                  SizedBox(height: 8.0),
                  Text(formattedDate),
                  SizedBox(height: 16.0),
                  Text('Price: $price'),
                  SizedBox(height: 16.0),
                  Text(description),
                  SizedBox(height: 16.0),
                  Text('University: $university'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
