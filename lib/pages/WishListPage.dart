import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'ProductDetailPage.dart';

//위젯 임포트
import 'package:amtt/widgets/ProductCard.dart';

class WishListPage extends StatefulWidget {
  @override
  _WishListPageState createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchWishProducts() async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'ERROR_NO_USER', message: '로그인먼저');
    }
    QuerySnapshot wishlistSnapshot = await _firestore
        .collection('wishlist')
        .where('userID', isEqualTo: user.uid)
        .get();

    List<String> postIds =
        wishlistSnapshot.docs.map((doc) => doc['postId'] as String).toList();
    List<Map<String, dynamic>> wishProducts = [];
    for (String postId in postIds) {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(postId).get();
      if (productSnapshot.exists) {
        Map<String, dynamic> productData =
            productSnapshot.data() as Map<String, dynamic>;
        productData['postId'] = postId;
        wishProducts.add(productData);
      }
    }
    return wishProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0, //스크롤 해도 색상 바뀌지 않게
        backgroundColor: Colors.white,
        title: Text('찜 리스트'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.06.sw, vertical: 10),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchWishProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No products found.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final data = snapshot.data![index];
                final String postname = data['postName'] ?? 'No title';
                final String userName = data['userName'] ?? 'Unknown';
                final String price = data['productPrice'] ?? '가격정보 없음';
                final String category = data['category'] ?? 'No category'; // 목록 카테고리
                final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                final String formattedDate =
                DateFormat('yyyy-MM-dd').format(timestamp.toDate());
                final List<dynamic> imageUrls = data['imageUrls'] ?? [];

                try{

                  return Container(
                    margin: EdgeInsets.only(bottom: 0),
                    child: ProductCard(
                      title: postname,
                      price: price,
                      date: formattedDate,
                      //이미지 경로가 없으면 비어있는 거 보냄
                      imageUrl: imageUrls.firstOrNull ?? '',
                      userName: userName,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              postId: data['postId'],)));
                      },
                    ),
                  );

                }
                catch (e, stackTrace)
                {
                  print("에러발생");
                  print(stackTrace);
                }


              },
            );
          },
        ),
      )
    );
  }
}
