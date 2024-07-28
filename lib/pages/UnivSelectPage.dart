import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';

//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';
import 'package:amtt/widgets/BtnYesBG.dart';


class University {
  final String name;
  final double latitude;
  final double longitude;

  University({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class UnivSelectPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<UnivSelectPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;
  List<University> universities = [];

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _controller.text.isNotEmpty;
    });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContent(
          universities: [
            '서울대학교',
            '연세대학교',
            '고려대학교',
            '한양대학교',
            '서강대학교',
            '성균관대학교',
            '이화여자대학교',
            '중앙대학교',
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    fetchUniversities();
    _controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }



  Future<void> fetchUniversities() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('university').get();
      List<University> fetchedUniversities = querySnapshot.docs.map((doc) {
        return University.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        universities = fetchedUniversities;
      });
    } catch (e) {
      print('Error fetching universities: $e');
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  '대학장터에 \n오신것을 환영합니다!',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 16),

                Text(
                  '이용을 위해 원하시는 대학교를 설정해주세요',
                  style: TextStyle(fontSize: 16, color: Color(0xff767676)),
                ),

                SizedBox(height: 46),


                // 대학 검색 텍스트필드 공간
                RoundedTextField(labelText: '대학 검색',
                    controller: _controller,
                    obscureText: false
                ),


                SizedBox(height: 16),

                // 주변대학 찾기 버튼
                Center(
                  child: TextButton(
                    onPressed: _showBottomSheet,
                    child: Text('주변 대학 찾기', style: TextStyle(color: Colors.black, fontSize: 16),),
                  ),
                ),

                Spacer(),

                // 로그인 버튼
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('계정이 있으신가요?', style: TextStyle(color: Colors.black, fontSize: 16),),
                  ),
                ),

              ],
            ),
          ),

          //바닥에 등록 버튼 고정
          bottomNavigationBar: Container(
            child: Padding(
              padding: EdgeInsets.all(0.02.sw),
              child: BtnYesBG(btnText: '다음', onPressed: () => print('hello'),),
            ),
          ),

        ),
      ),
    );
  }
}

// 하단에서 올라오는 주변 대학 리스트 다이얼로그창
class BottomSheetContent extends StatelessWidget {
  final List<String> universities;

  BottomSheetContent({required this.universities});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단바 공간
          Text(
            '내 주변 대학 목록',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            '원하는 대학교를 리스트에서 찾은 후 선택버튼을 클릭하세요',
            style: TextStyle(fontSize: 16, color: Color(0xff767676)),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: universities.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 65,
                    margin: EdgeInsets.symmetric(vertical: 6), // 아이템 간 위아래 마진
                    decoration: BoxDecoration(
                      color: Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(12), // 둥근 모서리 값
                    ),
                    child: Padding(
                      // 내부 패딩 값
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            // 키워드 제목 텍스트
                            child: Text(
                              universities[index],
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          // 대학교 선택 버튼
                          Container(
                            width: 90,
                            child: ElevatedButton(
                              onPressed: () => print('${universities[index]} 선택됨'),
                              child: Text('선택'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}