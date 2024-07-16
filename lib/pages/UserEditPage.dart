import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//위젯 임포트
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:amtt/widgets/RoundedTextField.dart';

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
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0, //스크롤 해도 색상 바뀌지 않게
        backgroundColor: Colors.white,
        title: Text('프로필 수정'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.06.sw),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 0.02.sh),

              // 프로필 이미지 공간
              ProfileImageWithIcon(
                icon: Icons.person, // 사용자의 프로필 이미지 경로
                onTap: () {
                  print('이미지를 변경하는 코드 넣어야함!');
                },
              ),

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
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: RoundedTextField(labelText: '이메일', controller : _nickNameController, obscureText : false),
              ),

              // 이름 탭 제목 텍스트
              UserTabTitle(text: '이름'),

              // 이름 텍스트필드 공간
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: RoundedTextField(labelText: '이름', controller : _nameController, obscureText : false),
              ),

              // 전화번호 탭 제목 텍스트
              UserTabTitle(text: '전화번호'),

              // 전화번호 텍스트필드 공간
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: RoundedTextField(labelText: '전화번호', controller : _phoneNumberController, obscureText : false),
              ),

              // 학번, 학과 공간
              Row(
                children: [
                  // 학번
                  Expanded(
                    child: Column(
                      children: [
                        // 학번 탭 제목 텍스트
                        UserTabTitle(text: '학번'),

                        // 학번 텍스트필드 공간
                        Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          child: RoundedTextField(labelText: '학번', controller: _studentIdController, obscureText: false),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 15,),

                  // 학과
                  Expanded(
                    child: Column(
                      children: [
                        // 학과 탭 제목 텍스트
                        UserTabTitle(text: '학과'),

                        // 학과 텍스트필드 공간
                        Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          child: RoundedTextField(labelText: '학과', controller: _departmentController, obscureText: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 0.01.sh),

              // 계정 탈퇴 버튼 공간
              Container(
                width: double.infinity,
                height: 60,
                child: CustomCancelButton(
                  text: '계정 탈퇴',
                  onPressed: _deleteUser
                ),
              ),

              SizedBox(height: 0.01.sh),



              SizedBox(height: 0.01.sh),
            ],
          ),
        ),
      ),

      // 바닥 고정 앱바 - 저장 버튼 공간
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: EdgeInsets.all(0.06.sw),
              child: Container(
                height: 60,
                child: BtnYesBG(
                    btnText: '저장', onPressed: _updateUser),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 계정 정보 수정
  void _updateUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Firestore에서 사용자 데이터를 업데이트합니다.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'nickName': _nickNameController.text,
        'name': _nameController.text,
        'phoneNumber': _phoneNumberController.text,
        'studentId': _studentIdController.text,
        'school': _schoolController.text,
        'department': _departmentController.text,
      });

      print('User updated');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('수정되었습니다!')));
    }
  }

  // 계정 정보 삭제
  void _deleteUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Firestore에서 사용자 데이터를 삭제합니다.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .delete();

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

class ProfileImageWithIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ProfileImageWithIcon({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          //위젯 겹처서 쌓기 위해
          children: [
            // 프로필 이미지 공간(둥근배경)
            Material(
              shape: const CircleBorder(),
              color: Color(0xff7E7E7E), // 배경색 설정
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,

                  //TODO : 이미지 없어서 일단 아이콘으로 대체 나중에 이미지로 받아오게 해야함
                  child: Icon(
                    icon,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // 카메라 아이콘
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 0.03.sh),

        // 프로필 이미지 설정 제목 텍스트
        const Text(
          '프로필 이미지 설정',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 0.02.sh),
      ],
    );
  }
}

class CustomCancelButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomCancelButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Color(0xFFFADEDE)),
        foregroundColor: WidgetStateProperty.all(Color(0xFFE85858)),
        elevation: WidgetStateProperty.all(0),

        // 모든 상태에 대해 elevation을 0으로 설정
        padding: WidgetStateProperty.all(EdgeInsets.all(2)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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