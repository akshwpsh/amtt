import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'ProductDetailPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//위젯 임포트
import 'package:amtt/widgets/ProductCard.dart';

class MyProductsPage extends StatefulWidget {
  @override
  _MyProductspageState createState() => _MyProductspageState();
}

class _MyProductspageState extends State<MyProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<DocumentSnapshot> _userPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      QuerySnapshot userPostsSnapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();

      setState(() {
        _userPosts = userPostsSnapshot.docs;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인하고 오세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(0.04.sw),
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0, //스크롤 해도 색상 바뀌지 않게
            title: Text('내 게시글'),
            backgroundColor: Colors.white,
          ),
          body: Container(
            color: Colors.white,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _userPosts.isEmpty
                ? Center(child: Text('작성한 게시글이 없습니다.'))
                : ListView.builder(
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = _userPosts[index];

                final String postname = data['postName'] ?? 'No title';
                final String userName = data['userName'] ?? 'Unknown';
                final String price = data['productPrice'] ?? '가격정보 없음';
                final String category = data['category'] ?? 'No category'; // 목록 카테고리
                final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                final String formattedDate =
                DateFormat('yyyy-MM-dd').format(timestamp.toDate());
                final List<dynamic> imageUrls = data['imageUrls'] ?? [];
                //final String status = data['status'] ?? '';
                //TODO : 안보이는 오류로 막아둠 아래 오류임
                //The following StateError was thrown building:
                // Bad state: field "status" does not exist within the DocumentSnapshotPlatform

                try{

                  return Container(
                    margin: EdgeInsets.only(bottom: 0),
                    child: ProductCard(
                      title: postname,
                      price: price,
                      date: timestamp,
                      //이미지 경로가 없으면 비어있는 거 보냄
                      imageUrl: imageUrls.firstOrNull ?? '',
                      userName: userName,
                      status: '',
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
            ),
          ),
        ),
      ),
    );
  }
}
