import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 페이지 임포트
import 'ProductDetailPage.dart';
import 'ProductRegisterPage.dart';

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
    final selectedCategory = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetContent(categories: _categories);
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
            automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
            backgroundColor: Colors.white,
            // TODO : 여기 접속한 유저가 선택한 대학에 따라 설정되게 해야함
            title: Text('목포대학교',style: TextStyle(fontWeight: FontWeight.bold),),
            titleSpacing: 0,
            actions: [

              IconButton(onPressed: () => {print("알림버튼 클릭")}, icon: Icon(Icons.search, size: 30,)),
              IconButton(onPressed: () => {print("알림버튼 클릭")}, icon: Icon(Icons.notifications_none, size: 30,)),

            ],

          ),
          body: Column(
            children: <Widget>[

              SizedBox(height : 15),



              SizedBox(height: 15,),

              // 검색 필터, 글쓰기 버튼 공간
              Row(

                children: [

                  //검색필터 공간
                  Expanded(
                    flex: 2,
                    child: Container(

                      child: BtnNoBG(btnText : '검색조건', onPressed: _selectCategory
                      ),
                    ),

                  ),

                  SizedBox(width: 15,),

                  //글쓰기 버튼 공간
                  Expanded(
                    flex: 1,
                    child: Container(

                      child: BtnYesBG(
                          btnText : '글쓰기',
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
                            margin: EdgeInsets.only(bottom: 0), // 카드 아이템 간의 마진
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


class BottomSheetContent extends StatefulWidget {
  final List<String> categories;

  BottomSheetContent({required this.categories}); // 생성자 수정

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  String selected = '';

  @override
  Widget build(BuildContext context) {
    final _categories = widget.categories;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(0.03.sh),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 상단바 공간
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
                '검색 필터',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 48), // To balance the back button on the left
            ],
          ),

          SizedBox(height: 26),

          Text('카테고리 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          
          // 그리드 카테고리 아이템 공간
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 한 줄에 몇개 넣을건지
              crossAxisSpacing: 25, // 좌 우 간격
              mainAxisSpacing: 25, //위 아래 간격
              childAspectRatio: 1, // 비율, 높을수록 위아래로 납작해짐
            ),
            
            
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = selected == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selected = category;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal.withOpacity(0.2) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //그리드 아이템 내부 아이콘 ( 카테고리 아이콘 )
                        //TODO : 여기 각 카테고리 이름에 맞는 아이콘 나오도록 해야함
                        Icon(Icons.category, size: 24, color: isSelected ? Colors.teal : Colors.grey),
                        SizedBox(height: 8),
                        // 그리드 아이템 내부 텍스트 ( 카테고리 이름 )
                        Text(category, style: TextStyle(fontSize: 16 , color: isSelected ? Colors.teal : Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 26),
          Text('검색학과', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          //검색 학과 드롭다운 공간
          Container(),

          SizedBox(height: 26),
          Text('가격 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          //가격선택 슬라이더 공간
          Container(),

          Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              Expanded(
                flex: 1,
                child: BtnNoBG(btnText: '초기화',
                    onPressed: () {
                      setState(() {
                        selected = '';
                      });
                    }),
              ),

              SizedBox(width: 20,),

              Expanded(
                flex: 1,
                child: BtnYesBG(btnText: '검색',
                    onPressed: () {
                      //print(_selectedCategory);
                      Navigator.pop(context, selected);
                    }),
              ),





            ],
          ),
        ],
      ),
    );
  }
}
