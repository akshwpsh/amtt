import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amtt/widgets/UserDefaultTab.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'KeywordsPage.dart';
import 'WishListPage.dart';
import 'UserEditPage.dart';
import 'LoginPage.dart';
import 'MyProductsPage.dart';
import 'ChangeUnivPage.dart';

class UserPage extends StatefulWidget {
  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserPage> {
  String? _profileImageUrl;
  String? _Nickname;
  String? userEmail;
  String? _university;

  User? currentUser = FirebaseAuth.instance.currentUser;

  bool _notiEnabled = true;

  Future<void> _sendEmail() async {
    String supportEmail = "sophra1234@gmail.com";
    final Email email = Email(
      body: '보낸 사람: ${userEmail}\n 문의 내용을 입력해주세요.',
      subject: '문의하기',
      recipients: ['sophra1234@gmail.com'], // 수신자 이메일을 여기에 입력
      isHTML: false, // 일반 텍스트로 전송
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문의가 전송되었습니다.')),
      );
    } catch (error) {
      print(error);
      _showErrorDialog(supportEmail);
    }
  }

  void _showErrorDialog(String supportEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('문의 전송 실패'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('문의 전송에 실패했습니다. 다음 이메일 주소로 문의해주세요.'),
              SizedBox(height: 10),
              Text('이메일: $supportEmail'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 이메일 주소를 클립보드에 복사
                Clipboard.setData(ClipboardData(text: supportEmail));
                Navigator.of(context).pop();
              },
              child: Text(
                '이메일 복사',
                style: TextStyle(color: Color(0xFF4EBDBD)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '확인',
                style: TextStyle(color: Color(0xFF4EBDBD)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 유저 데이터 가져오기
    _loadSetting(); //세팅값 가져오기(지금은 알림만)
  }

  // 유저 데이터 가져오기
  Future<void> _loadUserData() async {
    // 현재 로그인된 사용자의 정보를 가져옵니다.
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {

      userEmail = FirebaseAuth.instance.currentUser!.email!;

      // Firestore에서 사용자 데이터를 가져옵니다.
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
      String? profileImageUrl = userData['imageUrl']; // 프로필 이미지 URL
      String? nickname = userData['nickName'];
      String? University = userData['school'];

      print(_profileImageUrl);
      setState(() {
        _profileImageUrl = profileImageUrl;
        _Nickname = nickname;
        _university = University;
      });
    }
  }

  Future<void> _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notiEnabled = prefs.getBool('notificationEnabled') ?? true;
    });

    print('불러온 알림설정상태: $_notiEnabled');
  }

  Future<void> _updateSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationEnabled', value);
    setState(() {
      _notiEnabled = value;
    });
    print('갱신한 알림설정상태: $_notiEnabled');
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nickname = _Nickname ?? "닉네임 정보 없음"; //닉네임
    final email = _Nickname ?? "닉네임 정보 없음"; //닉네임
    final university = _university ?? "대학 정보 없음"; //닉네임

    if(currentUser != null) {

      return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(0.04.sw),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              scrolledUnderElevation: 0, //스크롤 해도 색상 바뀌지 않게
              title: Text(
                '나의 정보',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              titleSpacing: 0, //  앱바 제목 왼쪽 마진 없애기
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 0.02.sh),

                  // 유저 프로필 공간
                  Material(
                    color: Color(0xffF7F8F8), // 여기에 원하는 배경색을 설정
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => {
                        //계정 정보 수정 페이지로 넘어가기
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserEditPage()),
                        )
                      }, //클릭 이벤트
                      highlightColor: Colors.grey.withOpacity(0.1), //길게 누를 때 색상
                      splashColor: Colors.grey.withOpacity(0.2), //탭 했을 때 잉크 효과 색상
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                        child: Row(
                          children: [
                            // 프로필 이미지
                            Material(
                              shape: const CircleBorder(),
                              color: Color(0xff7E7E7E), // 배경색 설정
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: _profileImageUrl != null
                                        ? DecorationImage(
                                      image:
                                      NetworkImage(_profileImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                  ),
                                  child: _profileImageUrl == null
                                      ? Icon(
                                    Icons.person,
                                    size: 34,
                                    color: Colors.white,
                                  )
                                      : null,
                                ),
                              ),
                            ),

                            SizedBox(width: 10),

                            // 사용자 정보 공간 (닉네임, 계정 이메일)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 사용자 닉네임 텍스트
                                  Text(
                                    nickname,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 4),

                                  // 사용자 계정 이메일 텍스트
                                  Text(
                                    userEmail!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 화살표 아이콘
                            Container(
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 0.02.sh),

                  //대학교 설정 탭 (대학교 이름, 변경 버튼)
                  Container(
                    child: Column(
                      children: [
                        //대학교 설정 탭 제목 텍스트
                        UserTabTitle(text: '대학교 설정'),

                        SizedBox(height: 0.01.sh),

                        Row(
                          children: [
                            //대학교 이름 텍스트
                            Text(university,
                                style: TextStyle(
                                    color: Color(0xff596773), fontSize: 20)),

                            Spacer(),

                            // 대학교 설정 변경 버튼 공간
                            CustomButton(
                              text: '변경',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChangeUnivPage()),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 0.01.sh),

                  //디바이더
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Color(0xffdbdbdb),
                  ),

                  //앱 관련 설정 탭 (알림 키워드 등록, 찜한 목록, 거래 기록)
                  Container(
                    child: Column(
                      children: [
                        //앱 관련 탭 제목 텍스트
                        UserTabTitle(text: '앱 관련'),

                        UsersdefaultTab(
                            icon: Icons.markunread_sharp,
                            text: '알림 키워드 관리',
                            onTap: () => {
                              //알림 키워드 관리 페이지로 넘어가기
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => KeywordsPage()),
                              )
                            }),

                        UsersdefaultTab(
                            icon: Icons.favorite,
                            text: '찜한 목록 보기',
                            onTap: () => {
                              //찜한 목록 페이지로 넘어가기
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WishListPage()),
                              )
                            }),

                        UsersdefaultTab(
                            icon: Icons.manage_search,
                            text: '내 게시글 보기',
                            onTap: () => {
                              print("거래 기록 버튼 클릭"),
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyProductsPage()),
                              )
                            }),
                      ],
                    ),
                  ),

                  //디바이더
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Color(0xffdbdbdb),
                  ),

                  //기타 설정 탭 (전체 설정, 문의 하기, 로그 아웃)
                  Container(
                    child: Column(
                      children: [
                        //기타 설정 탭 제목 텍스트
                        UserTabTitle(text: '기타'),

                        UsersdefaultTab(
                          icon: Icons.settings,
                          text: '알림 설정',
                          trailing: Switch(
                            activeColor: Color(0xFF4EBDBD),
                            value: _notiEnabled,
                            onChanged: (value) {
                              _updateSetting(value);
                            },
                          ),
                          onTap: () {},
                        ),

                        UsersdefaultTab(
                            icon: Icons.call,
                            text: '문의 하기',
                            onTap: () async => {_sendEmail()}),

                        UsersdefaultTab(
                            icon: Icons.logout_rounded,
                            text: '로그 아웃',
                            onTap: () async => {_signOut()}),
                      ],
                    ),
                  ),

                  //디바이더
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Color(0xffdbdbdb),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

    }
    else {

      return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.06.sw, vertical: 10),
          child: Scaffold (

            backgroundColor: Colors.white,

            appBar: AppBar(
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
              backgroundColor: Colors.white,
              title: Text(
                '나의 정보',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              titleSpacing: 0,
            ),

            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      '로그인이 필요한 기능입니다'
                  ),
                  SizedBox(height: 10,),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('로그인', style: TextStyle(color: Color(0xFF4EBDBD), fontSize: 18),),
                  ),
                ],
              ),
            ),

          ),
        ),

      );


    }
  }
}

class UserTabTitle extends StatelessWidget {
  final String text;

  const UserTabTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Color(0xFFDCF2F2)),
        foregroundColor: WidgetStateProperty.all(Color(0xFF4EBDBD)),
        elevation: WidgetStateProperty.all(0),
        // 모든 상태에 대해 elevation을 0으로 설정
        padding: WidgetStateProperty.all(EdgeInsets.all(2)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // 둥근 모서리
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}