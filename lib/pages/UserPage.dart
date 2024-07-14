import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
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
              Container(
                padding: EdgeInsets.all(10),
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xffF7F8F8),
                ),

                child: Row(
                  children: [

                    //이미지 박스
                    Container(
                      width: 80,
                      height: 80,
                      color: Colors.blue,
                      child: Center (
                        //프로필 이미지 공간
                        child: Image.network('src'),
                      ),
                    ),


                    //유저 프로필 정보 박스
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: const Column(
                        children: [

                          //유저 닉네임 텍스트
                          Text('목포대 불주먹'),

                          //유저 닉네임 텍스트
                          Text('목포대 불주먹'),

                        ],
                      ),
                    ),

                    Spacer(),

                    //아이콘 박스
                    Container(
                      width: 30,
                      height: 90,
                      child: Center(
                        child: Icon(
                          Icons.chevron_right,
                          size: 34,
                        ),
                      )
                    ),

                  ],
                ),

              ),


              //대학교 설정 탭 (대학교 이름, 변경 버튼)
              Container(),

              const Divider(
                height: 20,
                thickness: 2,
                indent: 0,
                endIndent: 0,
                color: Color(0xffdbdbdb),
              ),

              //앱 설정 탭 (알림 키워드 등록, 찜한 목록, 거래 기록)
              Container(),

              //기타 설정 탭 (전체 설정, 문의 하기, 로그 아웃)
              Container(),



            ],
          ),
        ),
      ),
    );
  }



}
