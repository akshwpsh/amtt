import 'package:amtt/pages/ProductRegisterPage.dart';
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:amtt/Service/FirebaseService.dart';
import 'ChatPage.dart';

//위젯 임포트
import 'package:amtt/widgets/ImageSlider.dart'; //이미지 슬라이더


class ProductDetailPage extends StatelessWidget {
  final String postId;
  late final String postUserId;

  ProductDetailPage({required this.postId});

  //로그인 여부 확인
  User? isLogin;
  User? user = FirebaseAuth.instance.currentUser;

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
    this.postUserId = postUserId;
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
          String category = data['category'];

          return FutureBuilder<bool>(
            future: canEdit(user!.uid, postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final bool isAuthor = snapshot.data ?? false;

                return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      backgroundColor: Colors.white,

                      title: Container(
                        child: Text('상세보기', style: TextStyle(fontWeight: FontWeight.bold),),

                      ),

                      //앱바 아이콘 버튼들
                      actions: [

                        Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Row(
                            children: [

                              if(isLogin != null)
                              //찜버튼
                                FavoriteButton(postId: postId),

                                PopupMenuButton<String>(
                                  color: Colors.white,
                                  icon: Icon(Icons.more_vert_rounded, color: Color(0xff4EBDBD)),
                                  onSelected: (String result) {
                                    switch (result) {
                                      case '공유하기':
                                        print('공유하기 선택됨');
                                        //TODO : 공유 기능 구현 해아함
                                        print(canEdit(user!.uid, postId));
                                        break;
                                      case '수정하기':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductRegisterPage(
                                                    postId: postId),
                                          ),
                                        );
                                        break;
                                      case '삭제하기':
                                        deletePost(context, postId);
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    List<PopupMenuEntry<String>> menuItems = [
                                      const PopupMenuItem<String>(
                                        value: '공유하기',
                                        child: Text('공유하기'),
                                      ),
                                    ];

                                    //작성자 본인이면 수정하기, 삭제하기 버튼이 보이도록
                                    if (isAuthor) {
                                      menuItems.addAll([
                                        const PopupMenuItem<String>(
                                          value: '수정하기',
                                          child: Text('수정하기'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: '삭제하기',
                                          child: Text('삭제하기'),
                                        ),
                                      ]);
                                    }

                                    return menuItems;
                                  },
                                ),
                                

                            ],
                          ),
                        ),



                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(height: 0.02.sh,),

                            // 이미지 공간
                            if (imageUrls.isNotEmpty)
                            //이미지 슬라이더
                              ImageSliderWithIndicator(imageUrls: imageUrls),

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
                                  // 프로필 이미지
                                  Container(
                                    width: 0.04.sh,
                                    height: 0.04.sh,
                                    margin: const EdgeInsets.only(right: 15),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    //TODO : 이미지가 없어서 임시로 아이콘 사용 => 이미지로 바꿔야함
                                    child: const Icon(
                                      Icons.person_pin,
                                      size: 44,
                                    ),
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
                            Text(
                              '카테고리 : $category',
                              style:
                              TextStyle(fontSize: 17, color: Color(0xff767676)),
                            ),
                            SizedBox(height: 0.01.sh),


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


                                //작성자 본인이 아니면 채팅하기 버튼이 보이도록
                                if(!isAuthor)
                                  Container(
                                    width: 0.3.sw,
                                    height: 0.05.sh,
                                    //채팅 버튼
                                    child: BtnYesBG(
                                      btnText: "채팅하기",
                                      onPressed: () async {
                                        // Check for an existing chat room
                                        String? existingChatId = await FirebaseService()
                                            .findExistingChatRoom(postId);

                                        String chatId;
                                        if (existingChatId != null) {
                                          // Use the existing chat room
                                          chatId = existingChatId;
                                        } else {
                                          // No existing chat room found, create a new one
                                          chatId = await FirebaseService()
                                              .createChatRoom(
                                              postUserId, postId, postName);
                                        }

                                        // Navigate to the chat room
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(chatId),
                                          ),
                                        );
                                      },
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
          if (e is FirebaseAuthException && e.code == 'ERROR_NO_USER') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('로그인먼저하세용')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('찜실패 오류확인하기')),
            );
          }
        }
        setState(() {});
      },
      color: Color(0xFF4EBDBD),
      icon: Icon(
        isZZim ? Icons.favorite : Icons.favorite_border,
      ),
    );
  }
}
