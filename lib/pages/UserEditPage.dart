import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEditPage extends StatefulWidget {
  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

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

      // 가져온 데이터를 각 TextEditingController에 설정합니다.
      _nickNameController.text = userData['nickName'];
      _nameController.text = userData['name'];
      _phoneNumberController.text = userData['phoneNumber'];
      _studentIdController.text = userData['studentId'];
      _schoolController.text = userData['school'];
      _departmentController.text = userData['department'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.06.sw),
        child: SingleChildScrollView(
          child: Column(
            children: [

              Container(),

              //디바이더
              const Divider(
                height: 20,
                thickness: 2,
                indent: 0,
                endIndent: 0,
                color: Color(0xffdbdbdb),
              ),

              // 닉네임 탭 제목 텍스트
              UserTabTitle(text: '닉네임'),

              // 닉네임 텍스트필드 공간
              Container(),

              // 이름 탭 제목 텍스트
              UserTabTitle(text: '이름'),

              // 이름 텍스트필드 공간
              Container(),

              // 전화번호 탭 제목 텍스트
              UserTabTitle(text: '전화번호'),

              // 전화번호 텍스트필드 공간
              Container(),

              // 학번, 학과 공간
              Row(

                children: [

                  // 학번
                  Column(
                    children: [

                      // 학번 탭 제목 텍스트
                      UserTabTitle(text: '학번'),

                      // 학번 텍스트필드 공간
                      Container(),

                    ],
                  ),

                  // 학과
                  Column(
                    children: [

                      // 학번 탭 제목 텍스트
                      UserTabTitle(text: '학번'),

                      // 학번 텍스트필드 공간
                      Container(),

                    ],
                  ),



                ],

              ),


              // 계정 탈퇴 버튼 공간
              Container(),




              TextField(
                controller: _nickNameController,
                decoration: InputDecoration(labelText: '닉네임'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: '전화번호'),
              ),
              TextField(
                controller: _studentIdController,
                decoration: InputDecoration(labelText: '학번'),
              ),
              TextField(
                controller: _schoolController,
                decoration: InputDecoration(labelText: '학교'),
              ),
              TextField(
                controller: _departmentController,
                decoration: InputDecoration(labelText: '학과'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('수정'),
              ),
              ElevatedButton(
                onPressed: _deleteUser,
                child: Text('회원 탈퇴'),
              ),
            ],
          ),
        ),
      ),

      // 바닥 고정 앱바 - 저장 버튼 공간
      bottomSheet: BottomAppBar(),
    );
  }
  void _updateUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Firestore에서 사용자 데이터를 업데이트합니다.
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'nickName': _nickNameController.text,
        'name': _nameController.text,
        'phoneNumber': _phoneNumberController.text,
        'studentId': _studentIdController.text,
        'school': _schoolController.text,
        'department': _departmentController.text,
      });

      print('User updated');
    }
  }

  void _deleteUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Firestore에서 사용자 데이터를 삭제합니다.
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).delete();

      // Firebase Authentication에서 사용자를 삭제합니다.
      await currentUser.delete();

      print('User deleted');
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