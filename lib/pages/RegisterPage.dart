import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
              ),
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
                onPressed: _register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      print('Passwords do not match');
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
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
}
