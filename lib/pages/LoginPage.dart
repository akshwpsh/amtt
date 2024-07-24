import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RegisterPage.dart';

import 'NavigatePage.dart';
import 'KeywordsPage.dart';
import '../Service/FirebaseService.dart';

import 'package:google_sign_in/google_sign_in.dart';

//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';
import 'package:amtt/widgets/TitleLogo.dart';
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:amtt/widgets/BtnNoBG.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //키보드 올라올때 사이즈 에러 방지
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        //전체 패딩
        padding: EdgeInsets.all(0.1.sw),
        child: Column(
          children: [
            //TODO : AppBar 지울 때 0.1.sh 로 변경!
            SizedBox(height: 0.02.sh),

            TitleLogo(), //로고

            SizedBox(height: 0.1.sh), // 로고와 텍스트필드 사이의 간격 추가

            Container(
              width: 0.8.sw,
              child: Column(
                children: [
                  //이메일 입력
                  RoundedTextField(
                      labelText: '이메일',
                      controller: _emailController,
                      obscureText: false),

                  SizedBox(height: 0.01.sh), // 로고와 텍스트필드 사이의 간격 추가

                  //비밀번호 입력
                  RoundedTextField(
                      labelText: '비밀번호',
                      controller: _passwordController,
                      obscureText: true),

                  SizedBox(height: 0.02.sh),

                  //로그인 버튼
                  BtnYesBG(btnText: '로그인', onPressed: _login),
                ],
              ),
            ),

            SizedBox(height: 0.02.sh),

            //이이디/비밀번호 찾기 버튼
            TextButton(
              onPressed: () {
                print('아이디/비밀번호 찾기 버튼 클릭');
              },
              child: Text('아이디 / 비밀번호 찾기',
                  style: TextStyle(
                      color: Color(0xFF767676), fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center),
            ),

            SizedBox(height: 0.01.sh),

            //회원가입 버튼
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage(isGoogleSignUp : false)),
                );
              },
              child: Text('회원가입',
                  style: TextStyle(
                      color: Color(0xFF2f2f2f), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),

            SizedBox(height: 0.1.sh),

            BtnNoBG(
                btnText: '로그인 없이 계속하기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NavigatePage()),
                  );
                }),
            //구글로 로그인하기
            BtnYesBG(btnText: '구글로 로그인', onPressed: _googleSignIn),
          ],
        ),
      ),
    );
  }

  void _login() async {
    try {
      print('email:' + _emailController.text);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('Login successful: $userCredential');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NavigatePage()),
      );
      FirebaseService().saveMessageToken();
    } catch (e) {
      print('Login failed: $e');
    }
  }

  void _googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NavigatePage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterPage(isGoogleSignUp: true, user: user),
            ),
          );
        }
      }
    } catch (e) {
      print('Google sign-in failed: $e');
    }
  }
}
