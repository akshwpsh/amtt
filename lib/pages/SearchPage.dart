import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 페이지 임포트
import 'ProductDetailPage.dart';

//위젯 임포트
import 'package:amtt/widgets/ProductCard.dart';
import 'package:amtt/widgets/BtnNoBG.dart';
import 'package:amtt/widgets/BtnYesBG.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController(); // 검색 텍스트필드 컨트롤러
  String? _searchText = '';
  List<String> _searchHistory = []; // 검색 기록 목록

  List<String> _selectedCategories = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories(); //카테고리 목록 가져오기
    _loadSearchHistory(); // 검색기록 가져오기
    _searchController.addListener(_onTextChanged); //검색컨트롤러에 텍스트 변화 리스너 추가
  }

  Future<void> _fetchCategories() async {
    try {
      DocumentSnapshot categoryDoc =
          await _firestore.collection('category').doc('categories').get();
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
    final selectedCategories = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetContent(
            categories: _categories, selectedCategories: _selectedCategories);
      },
    );
    if (selectedCategories != null) {
      setState(() {
        _selectedCategories = selectedCategories;
      });
    }
  }

  // 검색기록 가져오는 메서드
  Future<void> _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //검색기록 sharedpreferences 에서 가져와 _searchHistory 리스트에 넣음
      _searchHistory = prefs.getStringList('SearchHistory') ?? [];
    });
  }

  // 검색기록 추가하는 메서드
  Future<void> _addSearchHistory(String search) async {
    if (search.isNotEmpty && !_searchHistory.contains(search)) {
      setState(() {
        //_searchHistory 리스트에 검색기록 추가
        _searchHistory.add(search);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('SearchHistory', _searchHistory);
    }
  }

  // 검색기록 삭제하는 메서드
  Future<void> _removeSearchHistory(String search) async {
    setState(() {
      _searchHistory.remove(search);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', _searchHistory);
  }

  // 검색창 텍스트 비었는지 확인
  void _onTextChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchText = '';
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
          //키보드 올라올때 사이즈 에러 방지
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Container(
              height: 45,
              child: TextField(
                controller: _searchController, // 검색 텍스트필드 컨트롤러 연결
                autofocus: true, // 자동 포커스 설정
                onSubmitted: (value) {
                  setState(() {
                    _searchText = value;
                    _addSearchHistory(value);
                  });
                },
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    // 활성화 시 테두리 설정
                    borderSide: BorderSide(
                      color: Color(0xff4EBDBD), // 활성화 시 테두리 색상
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context), // 뒤로가기 버튼
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 30,
              ),

              // 검색기록 리스트 공간
              Visibility(
                visible: !_searchText!.isNotEmpty, // 검색어가 있으면 안보이게
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        '검색기록',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      width: double.infinity,
                    ),
                    Container(
                      height: 500,
                      child: ListView.builder(
                        itemCount: _searchHistory.length,
                        itemBuilder: (context, index) {
                          // 검색기록 아이템
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_searchHistory[index]),
                            onTap: () {
                              setState(() {
                                // 검색기록 탭했을 때 검색창 텍스트를 해당 텍스트로 설정하고 검색
                                _searchController.text = _searchHistory[index];
                                _searchText = _searchHistory[index];
                              });
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _removeSearchHistory(_searchHistory[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 검색결과 목록 공간
              Visibility(
                visible: _searchText!.isNotEmpty, //검색어가 비어져 있으면 숨김
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          '검색결과',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        width: double.infinity,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('products')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No products found.'));
                            }

                            final filteredDocs =
                                snapshot.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final String postName =
                                  data['postName'] ?? 'No title';
                              final String category = data['category'] ?? '';

                              final matchesSearchText = _searchText == null ||
                                  _searchText!.isEmpty ||
                                  postName
                                      .toLowerCase()
                                      .contains(_searchText!.toLowerCase());

                              final matchesCategory =
                                  _selectedCategories.isEmpty ||
                                      _selectedCategories.contains(category);

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
                                final String postname =
                                    data['postName'] ?? 'No title'; // 목록 제목
                                final String userName =
                                    data['userName'] ?? 'Unknown'; // 게시 유저명
                                final String price =
                                    data['productPrice'] ?? '가격정보 없음'; // 목록 가격
                                final String category = data['category'] ??
                                    'No category'; // 목록 카테고리
                                final Timestamp timestamp =
                                    data['timestamp'] ?? Timestamp.now();
                                final String formattedDate =
                                    DateFormat('yyyy-MM-dd')
                                        .format(timestamp.toDate()); // 게시 날짜
                                final List<dynamic> imageUrls =
                                    data['imageUrls'] ?? []; // 목록 이미지 리스트

                                try {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        bottom: 0), // 카드 아이템 간의 마진
                                    child: ProductCard(
                                      title: postname,
                                      price: price,
                                      date: formattedDate,
                                      //이미지 경로가 없으면 비어있는 거 보냄
                                      imageUrl: imageUrls.firstOrNull ?? '',
                                      userName: userName,
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetailPage(
                                                postId: doc.id,
                                              ),
                                            ));
                                      },
                                    ),
                                  );
                                } catch (e, stackTrace) {
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
              )
            ],
          ),
          // 바닥 고정 앱바 - 저장 버튼 공간
          bottomNavigationBar: Visibility(
            visible: _searchText!.isNotEmpty,
            child: Container(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Padding(
                    padding: EdgeInsets.all(0.06.sw),
                    child: Container(
                      height: 60,
                      child:
                          BtnNoBG(btnText: '결과 필터', onPressed: _selectCategory),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 하단에서 올라오는 결과 필터 다이얼로그창
class BottomSheetContent extends StatefulWidget {
  final List<String> categories;
  final List<String> selectedCategories;

  BottomSheetContent(
      {required this.categories, required this.selectedCategories}); // 생성자 수정

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late List<String> _selectedCategories;

  void initState() {
    super.initState();
    _selectedCategories = widget.selectedCategories;
  }

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
                  Navigator.pop(context, _selectedCategories);
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

          Text('카테고리 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              final isSelected = _selectedCategories.contains(category);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(category);
                    } else {
                      _selectedCategories.add(category);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.teal.withOpacity(0.2)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //그리드 아이템 내부 아이콘 ( 카테고리 아이콘 )
                        //TODO : 여기 각 카테고리 이름에 맞는 아이콘 나오도록 해야함
                        Icon(Icons.category,
                            size: 24,
                            color: isSelected ? Colors.teal : Colors.grey),
                        SizedBox(height: 8),
                        // 그리드 아이템 내부 텍스트 ( 카테고리 이름 )
                        Text(category,
                            style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.teal : Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          /*
          SizedBox(height: 26),
          Text('검색학과', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

           */

          //검색 학과 드롭다운 공간
          Container(),

          SizedBox(height: 26),
          Text('가격 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          //가격선택 슬라이더 공간
          Container(),

          Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 1,
                child: BtnNoBG(
                    btnText: '초기화',
                    onPressed: () {
                      setState(() {
                        _selectedCategories.clear();
                      });
                    }),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                flex: 1,
                child: BtnYesBG(
                    btnText: '검색',
                    onPressed: () {
                      //print(_selectedCategory);
                      Navigator.pop(context, _selectedCategories);
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
