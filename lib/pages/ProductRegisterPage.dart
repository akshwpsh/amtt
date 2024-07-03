import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ProductRegisterPage extends StatefulWidget {
  @override
  _ProductRegisterState createState() => _ProductRegisterState();
}

class _ProductRegisterState extends State<ProductRegisterPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _postnameController = TextEditingController();
  final TextEditingController _postnaeyongController = TextEditingController();
  final TextEditingController _productpriceController = TextEditingController();
  List<XFile?> _selectedImages = [];
  List<String?> _imageUrls = [];
  final _imagePicker = ImagePicker();

  String? userName;
  String? userUniversity;

  @override
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
    }
  }

  Future<void> _selectImage() async {
    final pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles;
        _imageUrls = pickedFiles.map((pickedFile) => pickedFile.path).toList();
      });
    }
  }

  Future<List<String>> _uploadImagesToFirebase() async {
    List<String> downloadUrls = [];
    for (var image in _selectedImages) {
      if (image != null) {
        final storageRef = FirebaseStorage.instance.ref('product_images/${image.name}');
        if (kIsWeb) {
          // Web 환경에서 Uint8List로 변환하여 업로드
          Uint8List imageBytes = await image.readAsBytes();
          await storageRef.putData(imageBytes);
        } else {
          // 모바일 환경에서 File로 업로드
          await storageRef.putFile(File(image.path));
        }
        String downloadUrl = await storageRef.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    }
    return downloadUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Register'),
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
              ElevatedButton(
                onPressed: _selectImage,
                child: Text('이미지 선택'),
              ),
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 10,
                  children: _selectedImages
                      .asMap()
                      .entries
                      .map((entry) => (kIsWeb)
                      ? Image.network(
                    _imageUrls[entry.key]!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    File(entry.value!.path),
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ))
                      .toList(),
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
        final imageUrls = await _uploadImagesToFirebase();
        await _firestore.collection('products').add({
          'postname': _postnameController.text,
          'postnaeyong': _postnaeyongController.text,
          'productprice': _productpriceController.text,
          'userId': user.uid,
          'userName': userName,
          'userUniversity': userUniversity,
          'imageUrls': imageUrls,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('게시물 등록 성공')));
        _clearForm();
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('로그인하고 오세요')));
    }
  }

  void _clearForm() {
    _postnameController.clear();
    _postnaeyongController.clear();
    _productpriceController.clear();
    setState(() {
      _selectedImages = [];
      _imageUrls = [];
    });
  }
}

Future<bool> isUserLogin() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}
