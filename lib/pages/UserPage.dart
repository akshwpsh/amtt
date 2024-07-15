import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//위젯 임포트
import 'package:amtt/widgets/UserDefaultTab.dart';

class UserPage extends StatefulWidget {
  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // 현재 로그인된 사용자의 정보를 가져옵니다.
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Firestore에서 사용자 데이터를 가져옵니다.
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('나의 정보'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.06.sw),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 0.05.sh),

              // 유저 프로필 공간
              Material(
                color: Color(0xffF7F8F8), // 여기에 원하는 배경색을 설정
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => {},
                  //클릭 이벤트
                  highlightColor: Colors.grey.withOpacity(0.1),
                  //길게 누를 때 색상
                  splashColor: Colors.grey.withOpacity(0.2),
                  //탭 했을 때 잉크 효과 색상
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                    child: Row(
                      children: [
                        // 프로필 이미지
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          //TODO : 이미지가 없어서 임시로 아이콘 사용 => 이미지로 바꿔야함
                          child: const Icon(
                            Icons.person_pin,
                            size: 44,
                          ),
                        ),
                        SizedBox(width: 10),

                        // 사용자 정보 공간 (닉네임, 계정 이메일)
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 사용자 닉네임 텍스트
                              Text(
                                '홍홍길길동동',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),

                              // 사용자 계정 이메일 텍스트
                              Text(
                                'hongildong@gmail.com',
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
                    UserTabTitle(text : '대학교 설정'),

                    SizedBox(height: 0.01.sh),

                    Row(
                      children: [
                        //대학교 이름 텍스트
                        const Text('목포대학교', style: TextStyle(color: Color(0xff596773), fontSize: 20)),

                        Spacer(),

                        // 대학교 설정 변경 버튼 공간
                        CustomButton(
                          text: '변경',
                          onPressed: () {
                            // 버튼이 클릭되었을 때 실행할 코드
                            print('버튼이 클릭되었습니다!');
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
                child: Column (
                  children: [

                    //앱 관련 탭 제목 텍스트
                    UserTabTitle(text : '앱 관련'),

                    UsersdefaultTab(
                        icon: Icons.markunread_sharp,
                        text: '알림 키워드 관리',
                        onTap: () => { print("클릭") }
                    ),

                    UsersdefaultTab(
                        icon: Icons.favorite,
                        text: '찜한 목록 보기',
                        onTap: () => { print("클릭") }
                    ),

                    UsersdefaultTab(
                        icon: Icons.manage_search,
                        text: '거래 기록 보기',
                        onTap: () => { print("클릭") }
                    ),


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
              Container(),
            ],
          ),
        ),
      ),
    );
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
        elevation: WidgetStateProperty.all(0), // 모든 상태에 대해 elevation을 0으로 설정
        padding: WidgetStateProperty.all(EdgeInsets.all(2)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // 둥근 모서리 반경을 조절할 수 있습니다.
          ),
        ),
      ),

      child: Text(
        text,
        style: TextStyle(
          fontSize: 16, // 글씨 크기를 조절할 수 있습니다.
        ),
      ),
    );
  }
}
