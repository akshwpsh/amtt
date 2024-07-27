import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';
import 'package:amtt/widgets/BtnYesBG.dart';
import 'package:amtt/widgets/BtnNoBG.dart';

class UnivSelectPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<UnivSelectPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _controller.text.isNotEmpty;
    });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContent();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
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
            title: Text('대학장터에 오신것을 환영합니다!'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이용을 위해 보고 싶은 대학교를 설정해주세요',
                  style: TextStyle(fontSize: 16),
                ),

                SizedBox(height: 46),

                TextField(
                  controller: _controller,
                  cursorColor: Color(0xff4EBDBD),
                  decoration: InputDecoration(
                    hintText: '대학 검색',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff4EBDBD)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _showBottomSheet,
                    child: Text('주변 대학 찾기'),
                  ),
                ),
                Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled ? Color(0xff4EBDBD) : Colors.grey,
                    ),
                    child: Text('다음'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 하단에서 올라오는 주변 대학 리스트 다이얼로그창
class BottomSheetContent extends StatelessWidget {
  final List<String> universities = [
    '목포대학교',
    '목포대학교',
    '목포대학교',
    '목포대학교',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.03.sh),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // 상단바 공간
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                '내 주변 대학 목록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 48), // To balance the back button on the left
            ],
          ),

          SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: universities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(universities[index]),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // 버튼 클릭 시 처리 코드
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff4EBDBD),
                    ),
                    child: Text('선택'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}