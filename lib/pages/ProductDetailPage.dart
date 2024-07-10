import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세보기'),
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

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(0.1.sw),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrls.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xff767676),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    imageUrls[index],
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      ),

                    SizedBox(height: 0.01.sh),

                    //판매자 정보 공간
                    const Divider(
                      height: 20,
                      thickness: 2,
                      indent: 0,
                      endIndent: 0,
                      color: Color(0xffdbdbdb),
                    ),

                    Container(
                      height: 0.05.sh,
                      child: Row (
                        children: [

                          //유저 프로필 사진 공간
                          Container(
                            width: 0.04.sh,
                            height: 0.04.sh,
                            color: Colors.blueGrey,
                            margin: const EdgeInsets.only(right: 15),
                          ),

                          //유저명
                          Text('$userName', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)
                          ),

                          Spacer(),

                          Text('$university'),

                        ],
                      ),
                    ),

                    const Divider(
                      height: 20,
                      thickness: 2,
                      indent: 0,
                      endIndent: 0,
                      color: Color(0xffdbdbdb),
                    ),


                    //게시글 제목
                    Text(
                      postName,
                      style:
                      TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 0.01.sh),

                    //게시글 상태정보 나열(날짜, 뷰, 찜, 채팅)
                    Row(
                      children: [
                        Text(formattedDate, style: TextStyle(color: Color(0xff767676)),),
                      ],
                    ),

                    SizedBox(height: 0.01.sh),

                    Text('Price: $price'),
                    SizedBox(height: 0.01.sh),
                    Text(description, style: TextStyle(color: Color(0xff767676)),),
                    SizedBox(height: 0.01.sh),

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
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.yellow,
          height: 50.0,
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('This is Bottom'),
                Icon(Icons.arrow_downward),
              ]
          ),
        ),
      ),
    );
  }
}


