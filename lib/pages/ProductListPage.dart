import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 페이지 임포트
import 'ProductDetailPage.dart';
import 'ProductRegisterPage.dart';
import 'SearchPage.dart';

//위젯 임포트
import 'package:amtt/widgets/ProductCard.dart';

class ProductListPage extends StatefulWidget {
  final String university;

  ProductListPage({Key? key, required this.university}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _searchText = '';
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String university = widget.university;
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(0.04.sw),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            scrolledUnderElevation: 0, //스크롤 해도 색상 바뀌지 않게
            automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
            backgroundColor: Colors.white,
            // TODO : 여기 접속한 유저가 선택한 대학에 따라 설정되게 해야함
            title: Text(
              university,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            titleSpacing: 0,
            actions: [
              IconButton(
                  onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchPage()),
                        )
                      },
                  icon: Icon(
                    Icons.search,
                    size: 30,
                  )),
              /*
              IconButton(
                  onPressed: () => {print("알림버튼 클릭")},
                  icon: Icon(
                    Icons.notifications_none,
                    size: 30,
                  )),*/
            ],
          ),
          body: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),

              // 검색 필터, 글쓰기 버튼 공간
              Row(
                children: [
                  /*
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

                  ),*/
                ],
              ),

              SizedBox(
                height: 15,
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('products')
                      .where('University', isEqualTo: widget.university)
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
                      return Center(child: Text('게시글 없음'));
                    }



                    final filteredDocs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String postName = data['postName'] ?? 'No title';
                      final String category = data['category'] ?? '';
                      final String status = data['status'] ?? '판매중';

                      final matchesSearchText = _searchText == null ||
                          _searchText!.isEmpty ||
                          postName
                              .toLowerCase()
                              .contains(_searchText!.toLowerCase());
                      final matchesCategory = _selectedCategories.isEmpty ||
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
                        final String category =
                            data['category'] ?? 'No category'; // 목록 카테고리
                        final Timestamp timestamp =
                            data['timestamp'] ?? Timestamp.now();
                        final String formattedDate = DateFormat('yyyy-MM-dd')
                            .format(timestamp.toDate()); // 게시 날짜
                        final List<dynamic> imageUrls =
                            data['imageUrls'] ?? []; // 목록 이미지 리스트
                        final String status = data['status'] ?? '판매중';

                        try {
                          return Container(
                            margin: EdgeInsets.only(bottom: 0), // 카드 아이템 간의 마진
                            child: ProductCard(
                              title: postname,
                              price: price,
                              date: timestamp,
                              //이미지 경로가 없으면 비어있는 거 보냄
                              imageUrl: imageUrls.firstOrNull ?? '',
                              userName: userName,
                              status: status,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
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
          floatingActionButton: Container(
            width: 130,
            child: CustomFloatingActionButton(
              onPressed: () async {
                if (await isUserLogin()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductRegisterPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("로그인이 필요한 기능입니다")),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: const Color(0xFF4EBDBD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white),
            const SizedBox(width: 8.0),
            const Text('글쓰기', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
