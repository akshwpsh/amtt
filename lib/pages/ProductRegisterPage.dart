import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import "../Service/FirebaseService.dart";

//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';
import 'package:amtt/widgets/TitleLogo.dart';
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:amtt/widgets/BtnNoBG.dart';

//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';
import 'package:amtt/widgets/TitleLogo.dart';
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:amtt/widgets/BtnNoBG.dart';

class ProductRegisterPage extends StatefulWidget {
  final String? postId;

  ProductRegisterPage({this.postId});

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
  String? _selectedCategory;
  List<String> _categories = [];
  bool get isEditMode => widget.postId != null;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _fetchCategories();
    if (isEditMode) {
      _loadProductData(widget.postId!);
    }
  }
   Future<void> _fetchCategories() async {
    try {
      DocumentSnapshot categoryDoc = await _firestore.collection('category').doc('categories').get();
      Map<String, dynamic> data = categoryDoc.data() as Map<String, dynamic>;
      List<String> categories = [];
      data.forEach((key, value) {
        categories.add(value);
      });
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print("Failed to fetch categories: $e");
      // 오류가 발생하면 임시 카테고리들로 설정
      setState(() {
        _categories = ['전자제품', '책', '문구', '생활용품', '의류', '취미'];
      });
    }
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

  Future<void> _loadProductData(String postId) async {
    DocumentSnapshot productData =
        await _firestore.collection('products').doc(postId).get();
    setState(() {
      _postNameController.text = productData['postName'];
      _postDescriptionController.text = productData['postDescription'];
      _productPriceController.text = productData['productPrice'];
      _imageUrls = List<String>.from(productData['imageUrls']);
      _selectedCategory = productData['category'];
    });
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

  void _selectCategory() async {
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('카테고리 선택'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _categories.map((category) {
                return ListTile(
                  title: Text(category),
                  onTap: () {
                    Navigator.pop(context, category);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    if (selectedCategory != null) {
      setState(() {
        _selectedCategory = selectedCategory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0, //스크롤 해도 색상 바뀌지 않게
        backgroundColor: Colors.white,
        title: Text('게시글 등록'),
      ),
      body: Theme(
        data: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.black), // 라벨 텍스트 색상 설정
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Color(0xff4EBDBD)), // 포커스된 상태에서의 밑줄 색상
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            //전체 패딩
            padding: EdgeInsets.all(0.1.sw),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _postNameController,
                    cursorColor: Color(0xff4EBDBD),
                    decoration: const InputDecoration(
                      labelText: '게시글 제목',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffdbdbdb)), // 선택되지 않았을 때의 테두리 색상
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xff4EBDBD)), // 포커스된 상태에서의 밑줄 색상 변경
                      ),
                    ),
                  ),

                  SizedBox(height: 0.05.sh),

                  TextField(
                      controller: _postDescriptionController,
                      decoration: const InputDecoration(
                          labelText: '게시글 내용', alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffdbdbdb)), // 선택되지 않았을 때의 테두리 색상
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xff4EBDBD)), // 포커스된 상태에서의 밑줄 색상 변경
                        ),
                      ),
                      maxLines: 10),
                  SizedBox(height: 0.05.sh),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _productPriceController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '가격',
                      suffixText: '원',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffdbdbdb)), // 선택되지 않았을 때의 테두리 색상
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xff4EBDBD)), // 포커스된 상태에서의 밑줄 색상 변경
                      ),
                    ),
                  ),
                  //가격 필드와 이미지 등록 버튼 사이의 간격
                  SizedBox(height: 0.05.sh),

                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('카테고리 선택')
                  ),

                  SizedBox(height: 5,),

                  // 카테고리 선택 버튼
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      highlightColor: Colors.grey.withOpacity(0.1), //길게 누를 때 색상
                      splashColor: Colors.grey.withOpacity(0.2), //탭 했을 때 잉크 효과 색상
                      borderRadius: BorderRadius.circular(12),
                      onTap: _selectCategory,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFDBDBDB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCategory ?? '카테고리 선택',
                              style: TextStyle(color: Colors.black),
                            ),
                            Spacer(),
                            Icon(Icons.category, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),


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
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(0.03.sw),
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
        if (isEditMode) {
          await _firestore.collection('products').doc(widget.postId).update({
            'postName': _postNameController.text,
            'postDescription': _postDescriptionController.text,
            'productPrice': _productPriceController.text,
            'imageUrls': imageUrls,
            'category': _selectedCategory,
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('수정 완료')));
        } else {
          DocumentReference doc = await _firestore.collection('products').add({
            'postName': _postNameController.text,
            'postDescription': _postDescriptionController.text,
            'productPrice': _productPriceController.text,
            'userId': user.uid,
            'userName': userName,
            'University': userUniversity,
            'imageUrls': imageUrls,
            'category': _selectedCategory,
            'timestamp': FieldValue.serverTimestamp(),
            'status' : '판매중',
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('게시물 등록 성공')));
          FirebaseService()
              .notifyUsersByTitle(_postNameController.text, doc.id);
        }
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
      _selectedCategory = null;
    });
  }
}

Future<bool> isUserLogin() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}
