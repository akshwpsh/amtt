import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatelessWidget {
  final String postId;

  ProductDetailPage({required this.postId});

  //로그인 여부 확인
  User? isLogin;

  Future<Map<String, dynamic>> fetchPostDetails(String postId) async {
    // Firestore에서 해당 postId로 데이터를 가져오는 예시입니다.
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(postId)
        .get();

    //로그인 여부 설정
    isLogin = FirebaseAuth.instance.currentUser;

    return doc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
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


          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text('상세보기'),
              ),
              body: SingleChildScrollView(
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
                            height: 0.3.sh,

                            //이미지 페이지를 넘기기 위한 위젯 - 이미지 슬라이드 하는 곳
                            child: PageView.builder(
                              itemCount: imageUrls.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  child: Center(
                                    child: ClipRRect(
                                      //이미지 둥근 모서리 값
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.network(
                                        imageUrls[index],
                                        //이미지가 뒤 컨테이너에 꽉차게 크기 설정
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover, //비율유지하면서 채우기
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      SizedBox(height: 0.02.sh),

                      const Divider(
                        height: 20,
                        thickness: 2,
                        indent: 0,
                        endIndent: 0,
                        color: Color(0xffdbdbdb),
                      ),

                      //유저 정보 공간
                      Container(
                        height: 0.05.sh,
                        child: Row(
                          children: [
                            //유저 프로필 사진 공간
                            Container(
                              width: 0.04.sh,
                              height: 0.04.sh,
                              color: Colors.blueGrey,
                              margin: const EdgeInsets.only(right: 15),
                            ),

                            //유저명
                            Text('$userName',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600)),

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

                      SizedBox(height: 0.02.sh),

                      //게시글 제목
                      Text(
                        postName,
                        style: TextStyle(
                            fontSize: 26.0, fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 0.01.sh),

                      //게시글 상태정보 나열(날짜, 뷰, 찜, 채팅)
                      Row(
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                                fontSize: 17, color: Color(0xff767676)),
                          ),
                        ],
                      ),

                      SizedBox(height: 0.01.sh),

                      //게시글 내용
                      Text(
                        description,
                        style:
                            TextStyle(fontSize: 17, color: Color(0xff767676)),
                      ),

                      SizedBox(height: 0.01.sh),

                      //로그인 여부에 따른 찜버튼 보이기
                      if(isLogin != null)

                        //찜버튼
                        FavoriteButton(postId: postId),


                    ],
                  ),
                ),
              ),

              ///하단 앱바 (가격, 채팅버튼)
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xffdbdbdb), width: 1.0),
                  ),
                ),
                child: BottomAppBar(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //가격 정보
                          Text('가격 : $price 원',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Container(
                            width: 0.3.sw,
                            height: 0.05.sh,

                            //채팅 버튼
                            child: BtnYesBG(
                              btnText: "채팅하기",
                              onPressed: () => print("채팅누름"),
                            ),
                          )
                        ],
                      ),
                    )),
              ));
        }
      },
    );
  }
}

//찜버튼 stateful위젯 클래스
class FavoriteButton extends StatefulWidget {
  final String postId;

  const FavoriteButton({Key? key, required this.postId}) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {

  //현재 찜 상태 나타내는 변수
  bool isZZim = false;

  //초기화
  @override
  void initState() {
    super.initState();
    FetchFavoriteStatus();
  }

  //찜 상태 가져오는 코드
  Future<void> FetchFavoriteStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'ERROR_NO_USER', message: '로그인먼저');
    }

    //이미 찜되어있는 항목인지 확인하기위한 스냅샷
    QuerySnapshot confirmQuery = await FirebaseFirestore.instance
        .collection('wishlist')
        .where('userID', isEqualTo: user.uid)
        .where('postId', isEqualTo: widget.postId)
        .get();

    //찜 상태를 업데이트
    setState(() {
      isZZim = confirmQuery.docs.isNotEmpty;
    });
  }


  //찜리스트에 추가 하는 코드
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
      //상태 업데이트
      setState(() {
        isZZim = false;
      });
      return "찜해제";
    } else {
      await FirebaseFirestore.instance.collection('wishlist').add({
        'postId': postId,
        'userID': user.uid,
      });
      //상태 업데이트
      setState(() {
        isZZim = true;
      });
      return "찜성공";
    }
  }



  @override
  Widget build(BuildContext context) {

    return IconButton(
      onPressed: () async {
        ///오류발생 이유 확인하기위한 트라이문
        try {
          String result = await addZZimList(widget.postId);
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
        setState(() {

        });
      },
      color: Color(0xFF4EBDBD),
      icon: Icon(
        isZZim ? Icons.favorite : Icons.favorite_border,
      ),
    );
  }
}

