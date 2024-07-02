import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Productregisterpage extends StatefulWidget {
  @override
  _Productregisterpage createState() => _Productregisterpage();
}

class _Productregisterpage extends State<Productregisterpage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _postnameController = TextEditingController();
  final TextEditingController _postnaeyongController = TextEditingController();
  final TextEditingController _productpriceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? userName;
  String? userUniversity;

  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    if (await isUserLogin()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          userName = userData['name'];
          userUniversity = userData['school'];
        });
      }
      //로그인 안했으면 로그인하라고 알려주는거 넣기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProductRegister'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _postnameController,
                decoration: InputDecoration(labelText: '게시글 제목'),
              ),
              TextField(
                  controller: _postnaeyongController,
                  decoration: InputDecoration(labelText: '게시글 내용'),
                  maxLines: 10),
              TextField(
                controller: _productpriceController,
                decoration: InputDecoration(labelText: '가격'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이미지'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _productRegister,
                child: Text('게시물 등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _productRegister() async {
    if (await isUserLogin()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot =
            await _firestore.collection('products').get();
        int docCount = querySnapshot.size + 1;
        String newDocID = '$docCount';

        await _firestore.collection('products').doc(newDocID).set({
          'postname': _postnameController.text, // 게시글 제목
          'postnaeyong': _postnaeyongController.text, // 게시글 내용
          'productprice': _productpriceController.text, // 가격
          'name': _nameController.text, // 이미지 <<바꿔야됨
          'userId': user.uid, // 유저 ID
          'userName': userName, // 이름
          'userUniversity': userUniversity, //  대학교
          'timestamp': FieldValue.serverTimestamp(), // 서버 타임스탬프
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('게시물등록성공')));
        _clearForm();
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('로그인하고오세요')));
    }
  }

  void _clearForm() {
    // 컨트롤러 각 필드 초기화하기
    _postnameController.clear();
    _postnaeyongController.clear();
    _productpriceController.clear();
    _nameController.clear();
  }
}

Future<bool> isUserLogin() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}
