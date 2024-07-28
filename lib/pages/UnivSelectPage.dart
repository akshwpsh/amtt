import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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

  // 하단 주변 대학 설정 바 올라오게 하는 메서드
  Future<void> _showBottomSheet() async {
    Position currentPosition = await _getCurrentLocation();
    List<String> nearbyUniversities = _filterUniversitiesByDistance(currentPosition);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContent(
          universities: nearbyUniversities,
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    fetchUniversities();
  }


  // 대학 리스트 가져오는 메서드
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


  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // 위치 서비스가 활성화되어 있지 않으면 오류를 반환
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 활성화 되어 있지 않음');
    }

    // 위치 권한을 확인합니다.
    permission = await Geolocator.checkPermission();

    // 권한이 거부된 경우 권한 요청
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      
      // 권한 요청이 거부 시 에러
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    // 권한이 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          '위치 권한이 영구적으로 거부되어 요청을 할 수 없습니다.');
    }

    // 장치 위치 가져오기(권한 허용상태)
    return await Geolocator.getCurrentPosition();
  }

  // 현재 위치를 기준으로 대학교를 기준거리에 따라 필터링 하는 메서드
  List<String> _filterUniversitiesByDistance(Position currentPosition) {
    List<String> nearbyUniversities = [];

    for (var university in universities) {

      // 현재 위치와 대학 위치 사이의 거리를 미터 단위로 계산
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        university.latitude,
        university.longitude,
      );
      // 거리가 20km 이내인 경우 대학 이름을 리스트에 추가.
      if (distanceInMeters <= 20000) { // TODO : 하드코딩된 값이라 추후 외부에서 수정할 수 있게
        nearbyUniversities.add(university.name);
      }
    }
    // 필터링된 대학 리스트를 반환
    return nearbyUniversities;
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
                            child: BtnYesBG(btnText: '선택', onPressed: () { print('${universities[index]} 선택됨'); },),
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