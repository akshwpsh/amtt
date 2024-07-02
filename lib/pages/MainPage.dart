import 'package:amtt/pages/ProductRegisterPage.dart';
import 'package:flutter/material.dart';

import 'RegisterPage.dart';
import 'LoginPage.dart';
import 'UserEditPage.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  MaterialPageRoute(builder: (context) => RegisterPage()),
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
                        builder: (context) => Productregisterpage()),
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
