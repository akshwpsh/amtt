import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProductRegisterPage.dart';

class MyProductsPage extends StatefulWidget {
  @override
  _MyProductspageState createState() => _MyProductspageState();
}

class _MyProductspageState extends State<MyProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<DocumentSnapshot> _userPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      QuerySnapshot userPostsSnapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();

      setState(() {
        _userPosts = userPostsSnapshot.docs;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인하고 오세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 게시글'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userPosts.isEmpty
          ? Center(child: Text('작성한 게시글이 없습니다.'))
          : ListView.builder(
        itemCount: _userPosts.length,
        itemBuilder: (context, index) {
          DocumentSnapshot post = _userPosts[index];
          return ListTile(
            title: Text(post['postName']),
            subtitle: Text(post['postDescription']),
            onTap: () {
              // Navigate to the detail/edit page for the post
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductRegisterPage(postId: post.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
