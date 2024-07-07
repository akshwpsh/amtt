import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';
import 'package:amtt/widgets/TitleLogo.dart';
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:amtt/widgets/BtnNoBG.dart';

class ProductRegisterPage extends StatefulWidget {
  @override
  _ProductRegisterState createState() => _ProductRegisterState();
}

class _ProductRegisterState extends State<ProductRegisterPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _postNameController = TextEditingController();
  final TextEditingController _postDescriptionController =
      TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
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
        final storageRef =
            FirebaseStorage.instance.ref('product_images/${image.name}');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('게시글 등록'),
      ),
      body: Theme (
        data: ThemeData (

          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.black), // 라벨 텍스트 색상 설정
            focusedBorder: UnderlineInputBorder(
              borderSide:
              BorderSide(color: Color(0xff4EBDBD)), // 포커스된 상태에서의 밑줄 색상
            ),

          ),

        ),
        child: SingleChildScrollView (
          child: Padding(
            //전체 패딩
            padding: EdgeInsets.all(0.1.sw),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _postNameController,
                    cursorColor: Color(0xff4EBDBD),
                    decoration: InputDecoration(
                      labelText: '게시글 제목',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xff4EBDBD)), // 포커스된 상태에서의 밑줄 색상 변경
                      ),
                    ),
                  ),

                  SizedBox(height: 0.05.sh),

                  TextField(
                      controller: _postDescriptionController,
                      decoration: InputDecoration(labelText: '게시글 내용', alignLabelWithHint: true),
                      maxLines: 10),

                  SizedBox(height: 0.05.sh),


                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _productPriceController,
                    decoration: InputDecoration(labelText: '가격', suffixText: '원',),
                  ),

                  //가격 필드와 이미지 등록 버튼 사이의 간격
                  SizedBox(height: 0.05.sh),

                  BtnNoBG(btnText: '이미지 등록', onPressed: _selectImage),

                  SizedBox(height: 0.03.sh),
                  if (_selectedImages.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _selectedImages
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                          padding: EdgeInsets.only( right: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0.03.sw),
                            child: (kIsWeb)
                                ? Image.network(
                              _imageUrls[entry.key]!,
                              height: 0.2.sw,
                              width: 0.2.sw,
                              fit: BoxFit.cover,
                            )
                                : Image.file(
                              File(entry.value!.path),
                              height: 0.2.sw,
                              width: 0.2.sw,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                    ),

                  SizedBox(height: 0.05.sh),


                ],
              ),
            ),
          ),
        ),
      ),

      //바닥에 등록 버튼 고정
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(0.1.sw),
        child: BtnYesBG(btnText: '게시글 등록', onPressed: _productRegister),

      ),
    );
  }

  void _productRegister() async {
    if (await isUserLogin()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final imageUrls = await _uploadImagesToFirebase();
        await _firestore.collection('products').add({
          'postName': _postNameController.text,
          'postDescription': _postDescriptionController.text,
          'productPrice': _productPriceController.text,
          'userId': user.uid,
          'userName': userName,
          'University': userUniversity,
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
    _postNameController.clear();
    _postDescriptionController.clear();
    _productPriceController.clear();
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
