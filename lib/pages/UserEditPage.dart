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
        title: Text('회원정보 수정'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
