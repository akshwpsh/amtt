import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'ProductDetailPage.dart';

//위젯 임포트
import 'package:amtt/widgets/ProductCard.dart';
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:amtt/widgets/BtnNoBG.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _searchText = '';
  String? _selectedCategory;
  TextEditingController _searchController = TextEditingController();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
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
      // 오류가 발생하면 임시 카테고리로바꾸기
      setState(() {
        _categories = ['전자제품', '책', '문구', '생활용품', '의류', '취미'];
      });
    }
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
    } else {
      setState(() {
        _selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(0.04.sw),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text('상품 목록'),
            actions: [

              IconButton(onPressed: () => {print("알림버튼 클릭")}, icon: Icon(Icons.notifications_rounded), color: Color(0xff4EBDBD),),

            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "검색하세용",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              _searchText = _searchController.text;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: _selectCategory,
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: <Widget>[

              SizedBox(height : 15),

              // 검색 필드 공간
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Color(0xff4EBDBD),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Color(0xff4EBDBD)),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: '목록 검색',
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Color(0xff4EBDBD)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15,),

              // 검색 필터, 글쓰기 버튼 공간
              Row(

                children: [

                  //검색필터 공간
                  Expanded(
                    flex: 2,
                    child: Container(

                      child: BtnNoBG(btnText : '검색조건', onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return BottomSheetContent();
                          },
                        );
                      },
                      ),
                    ),

                  ),

                  SizedBox(width: 15,),

                  //글쓰기 버튼 공간
                  Expanded(
                    flex: 1,
                    child: Container(

                      child: BtnYesBG(btnText : '글쓰기', onPressed : () => {
                        print("검색조건 클릭")

                      }),

                    ),

                  ),
                ],

              ),

              SizedBox(height: 15,),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('products')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No products found.'));
                    }

                    final filteredDocs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String postName = data['postName'] ?? 'No title';
                      final String category = data['category'] ?? '';

                      final matchesSearchText = _searchText == null ||
                          _searchText!.isEmpty ||
                          postName.toLowerCase().contains(_searchText!.toLowerCase());
                      final matchesCategory = _selectedCategory == null ||
                          _selectedCategory!.isEmpty ||
                          category == _selectedCategory;

                      return matchesSearchText && matchesCategory;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return Center(child: Text('검색하신 내용에 맞는 상품이없어용'));
                    }
                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final String postname = data['postName'] ?? 'No title'; // 목록 제목
                        final String userName = data['userName'] ?? 'Unknown'; // 게시 유저명
                        final String price = data['productPrice'] ?? '가격정보 없음'; // 목록 가격
                        final String category = data['category'] ?? 'No category'; // 목록 카테고리
                        final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                        final String formattedDate =
                            DateFormat('yyyy-MM-dd').format(timestamp.toDate()); // 게시 날짜
                        final List<dynamic> imageUrls = data['imageUrls'] ?? []; // 목록 이미지 리스트


                        try{

                          return Container(
                            margin: EdgeInsets.only(bottom: 20), // 카드 아이템 간의 마진
                            child: ProductCard(
                              title: postname,
                              price: price,
                              date: formattedDate,
                              //이미지 경로가 없으면 비어있는 거 보냄
                              imageUrl: imageUrls.firstOrNull ?? '',
                              userName: userName,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      postId: doc.id,
                                    ),
                                ));
                              },
                            ),
                          );

                        }
                        catch (e, stackTrace)
                        {
                          print("에러발생");
                          print(stackTrace);
                        }


                      },
                    );
                  },
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}


class BottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text(
                '제목',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 48), // To balance the back button on the left
            ],
          ),
          SizedBox(height: 16),
          Text('카테고리 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            isExpanded: true,
            items: <String>['카테고리 1', '카테고리 2', '카테고리 3'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {},
          ),
          SizedBox(height: 16),
          Text('가격 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Slider(
            value: 50,
            min: 0,
            max: 100,
            divisions: 10,
            label: '50',
            onChanged: (value) {},
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  // 초기화 버튼 기능
                },
                child: Text('초기화'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 저장 버튼 기능
                },
                child: Text('저장'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
