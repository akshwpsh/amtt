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

  Future<String> addZZimList(String postId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'ERROR_NO_USER', message: '로그인먼저');
    }

    //이미 찜되어있는 항목인지 확인하기위한 스냅샷
    QuerySnapshot confirmQuery = await FirebaseFirestore.instance
        .collection('wishlist')
        .where('userID', isEqualTo: user.uid)
        .where('postId', isEqualTo: postId)
        .get();
    if (confirmQuery.docs.isNotEmpty) {
      await confirmQuery.docs.first.reference.delete();
      return "찜해제";
    } else {
      await FirebaseFirestore.instance.collection('wishlist').add({
        'postId': postId,
        'userID': user.uid,
      });
      return "찜성공";
    }
  }

  Future<String> fetchUserAuth(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['auth'];
  }

  Future<bool> canEdit(String userId, String postId) async {
    String auth = await fetchUserAuth(userId);
    if (auth == 'admin') {
      return true;
    }
    DocumentSnapshot postDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(postId)
        .get();
    String postUserId = postDoc['userId'];
    return userId == postUserId;
  }

  void deletePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(postId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시물 삭제성공')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('실패오류:$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

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
                        String result = await addZZimList(postId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
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
                  if (user != null)
                    FutureBuilder<bool>(
                      future: canEdit(user.uid, postId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData && snapshot.data!) {
                          return Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  //게시물편집기능넣기
                                },
                                icon: Icon(Icons.edit),
                                label: Text('편집'),
                              ),
                              SizedBox(width: 8.0),
                              ElevatedButton.icon(
                                onPressed: () {
                                  deletePost(context, postId);
                                },
                                icon: Icon(Icons.delete),
                                label: Text('삭제'),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
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
