import 'package:flutter/material.dart';

class BtnYesBG extends StatelessWidget {
  final String btnText; //labelText 내용 받는 변수
  final VoidCallback onPressed; //눌렀을 때 이벤트
  const BtnYesBG({Key? key, required this.btnText, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        //minimumSize: Size(425, 50),
        minimumSize: Size.fromHeight(50),
        foregroundColor: Colors.white, backgroundColor: Color(0xFF4EBDBD), // 글자색은 하얀색
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // 버튼 안의 패딩 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
        ),
      ),
      child: Text(
        btnText, // 버튼에 표시할 텍스트
        style: TextStyle(fontSize: 18), // 텍스트 스타일 설정
      ),
    );
  }
}