import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatelessWidget {
  final String postId;

  ProductDetailPage({required this.postId});

  Future<Map<String, dynamic>> fetchPostDetails(String postId) async {
    // Firestore에서 해당 postId로 데이터를 가져오는 예시입니다.
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(postId)
        .get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> addZZimList(String postId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'ERROR_NO_USER', message: '로그인먼저');
    }
    await FirebaseFirestore.instance.collection('wishlist').add({
      'postId': postId,
      'userID': user.uid,
    });
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
            String formattedDate =
                DateFormat('yyyy-MM-dd').format(timestamp.toDate());
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
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
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
                  SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () async {
                      ///오류발생 이유 확인하기위한 트라이문
                      ///나중에 로그인 확인 함수로 바꾸기 아니면 걍 냅둬도?
                      try {
                        await addZZimList(postId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('찜했습니당')),
                        );
                      } catch (e) {
                        if (e is FirebaseAuthException &&
                            e.code == 'ERROR_NO_USER') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('로그인먼저하세용')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('찜실패 오류확인하기')),
                          );
                        }
                      }
                    },
                    icon: Icon(Icons.favorite),
                    label: Text('찜하기'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
