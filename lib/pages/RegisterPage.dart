import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

//위젯 임포트
import 'package:amtt/widgets/BtnYesBG.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  //현재 페이지 변수
  int _currentPage = 0;

  //다음페이지로 이동
  void _nextPage() {
    if (_currentPage < 4) {
      setState(() {
        _currentPage += 1;
      });
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _register();
    }
  }

  //이전 페이지로 이동
  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage -= 1;
      });
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      print('Passwords do not match');
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'nickName': _nickNameController.text.trim(),
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim().replaceAll('-', ''),
        'studentId': _studentIdController.text.trim(),
        'school': _schoolController.text.trim(),
        'department': _departmentController.text.trim(),
        'registeredAt': FieldValue.serverTimestamp(),
      });

      print('Registration successful: $userCredential');
    } catch (e) {
      print('Registration failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //키보드 올라올때 사이즈 에러 방지
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('회원가입'),
          leading: _currentPage > 0
              ? IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _previousPage,
          )
              : null,
        ),
        bottomSheet: Container (
          color: Colors.white,
          child: SafeArea (
            child: Padding (
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding (
                  padding: EdgeInsets.all(0.1.sw),
                  child: Container (
                      height: 0.15.sh,
                      child: Column (
                        children: [

                          Container(
                            alignment: FractionalOffset.bottomRight,
                            child: Text('${_currentPage + 1}/5'),
                          ),
                          Container(
                            child: LinearProgressIndicator(
                              value: (_currentPage + 1) / 5,
                              backgroundColor: Color(0xFFDBDBDB),
                              color: Color(0xFF4EBDBD),
                            ),
                          ),
                          SizedBox(height: 0.03.sh),
                          //다음 버튼

                          BtnYesBG(btnText: _currentPage < 4 ? '다음' : '등록', onPressed: _nextPage),
                        ],
                      )
                  )
              ),
            ),
          ),
        ),
        body: Padding (
          padding: EdgeInsets.all(0.1.sw),
          child: Column(
            children: [

              //회원가입 폼 - 페이지뷰
              Expanded(
                  flex: 4,
                  child: Container(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        SignUpStep1(emailController: _emailController),
                        SignUpStep2(passwordController: _passwordController, confirmPasswordController: _confirmPasswordController),
                        SignUpStep3(nickNameController: _nickNameController),
                        SignUpStep4(nameController: _nameController, phoneNumberController: _phoneNumberController),
                        SignUpStep5(studentIdController: _studentIdController, schoolController: _schoolController, departmentController: _departmentController),
                      ],
                    ),
                  )
              ),

              //하단 인디케이터와 버튼 모음
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                  child: Column(
                    children: [


                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}

class SignUpStep1 extends StatelessWidget {
  final TextEditingController emailController;

  SignUpStep1({required this.emailController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('가입하려는 이메일 주소를 작성해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: '이메일 작성',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpStep2 extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  SignUpStep2({required this.passwordController, required this.confirmPasswordController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('비밀번호를 입력해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: '8자리 이상 입력',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          SizedBox(height: 20),
          TextField(
            controller: confirmPasswordController,
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}

class SignUpStep3 extends StatelessWidget {
  final TextEditingController nickNameController;

  SignUpStep3({required this.nickNameController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('닉네임을 입력해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          TextField(
            controller: nickNameController,
            decoration: InputDecoration(
              labelText: '닉네임',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpStep4 extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneNumberController;

  SignUpStep4({required this.nameController, required this.phoneNumberController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이름과 전화번호를 입력해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: '이름',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: phoneNumberController,
            decoration: InputDecoration(
              labelText: '전화번호',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpStep5 extends StatelessWidget {
  final TextEditingController studentIdController;
  final TextEditingController schoolController;
  final TextEditingController departmentController;

  SignUpStep5({required this.studentIdController, required this.schoolController, required this.departmentController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('학번, 학교, 학과를 입력해주세요', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          TextField(
            controller: studentIdController,
            decoration: InputDecoration(
              labelText: '학번',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: schoolController,
            decoration: InputDecoration(
              labelText: '학교',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: departmentController,
            decoration: InputDecoration(
              labelText: '학과',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
