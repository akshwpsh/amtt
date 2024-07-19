import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// 페이지 임포트
import 'ProductDetailPage.dart';

//위젯 임포트
import 'package:amtt/widgets/ProductCard.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController(); // 검색 텍스트필드 컨트롤러
  String? _searchText = '';
  List<String> _searchHistory = []; // 검색 기록 목록

  @override
  void initState() {
    super.initState();
    // 검색 기록 로드 (옵션)
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.04.sw),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: TextField(
            controller: _searchController, // 검색 텍스트필드 컨트롤러 연결
            autofocus: true, // 자동 포커스 설정
            onSubmitted: (value) {
              setState(() {
                _searchText = value;
              });
              // 검색 기능 구현 (옵션)
            },
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // 뒤로가기 버튼
          ),
        ),
        body: Column(
          children: [
            Text('검색기록'),

            Visibility(
              visible: _searchText!.isNotEmpty,
              child: Expanded(child: StreamBuilder<QuerySnapshot>(
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

                    return matchesSearchText;
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
            )
          ],
        )
      ),
    );
  }
}