import 'package:flutter/material.dart';

import 'RegisterPage.dart';
import 'LoginPage.dart';
import 'UserEditPage.dart';
import 'ProductRegisterPage.dart';
import 'ProductListPage.dart';
import 'KeywordsPage.dart';
import 'WishListPage.dart';
import 'ChatRoomsPage.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //가려지는 위젯 오류 제거
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Go to Login Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Go to Register Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage(isGoogleSignUp: false)),
                );
              },
            ),
            ElevatedButton(
              child: Text('Go to User Edit Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserEditPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('상품을 등록하러 가보자잇'),
              onPressed: () async {
                if (await isUserLogin()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductRegisterPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("로그인하고와라잇")),
                  );
                }
              },
            ),
            ElevatedButton(
              child: Text('상품 목록 보기'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('알림 키워드'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KeywordsPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('찜리스트'),
              onPressed: () async {
                if (await isUserLogin()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WishListPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("로그인하고와라잇")),
                  );
                }
              },
            ),
            ElevatedButton(
              child: Text('채팅방'),
              onPressed: () async {
                if (await isUserLogin()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatRoomsPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("로그인하고와라잇")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
