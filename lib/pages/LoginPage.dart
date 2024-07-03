import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'RegisterPage.dart';

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
      appBar: AppBar(
        title: Text('Login'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(34.0),
        child: Column(
          children: [

            SizedBox(height: 150),

            TitleLogo(), //로고

            SizedBox(height: 54), // 로고와 텍스트필드 사이의 간격 추가

            Container(
              width: 325,
              child: Column (
                children: [
                  //이메일 입력
                  RoundedTextField(labelText: '이메일', controller : _emailController, obscureText : false),

                  SizedBox(height: 12), // 로고와 텍스트필드 사이의 간격 추가

                  //비밀번호 입력
                  RoundedTextField(labelText: '비밀번호', controller : _passwordController, obscureText : true),

                  SizedBox(height: 20),

                  //로그인 버튼
                  BtnYesBG(btnText: '로그인', onPressed : _login),
                ],
              ),
            ),

            SizedBox(height: 20),


            //이이디/비밀번호 찾기 버튼
            TextButton(
              onPressed: () {
                print('아이디/비밀번호 찾기 버튼 클릭');
              },
              child: Text('아이디 / 비밀번호 찾기',
                  style: TextStyle(color: Color(0xFF767676), fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center),
            ),

            SizedBox(height: 14),

            //회원가입 버튼
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('회원가입',
                  style: TextStyle(color: Color(0xFF2f2f2f), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),

            SizedBox(height: 140),

            BtnNoBG(btnText : '로그인 없이 계속하기', onPressed : () { print('로그인x 버튼 클릭'); }),


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
    } catch (e) {
      print('Login failed: $e');
    }
  }


}




