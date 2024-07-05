import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

//배경없는 외곽선만 있는 버튼
class BtnNoBG extends StatelessWidget {
  final String btnText; //labelText 내용 받는 변수
  final VoidCallback  onPressed; //눌렀을 때 이벤트
  const BtnNoBG({Key? key, required this.btnText, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        //minimumSize: Size(325, 50),
        minimumSize: Size.fromHeight(0.07.sh),
        foregroundColor: Color(0xFF4EBDBD), backgroundColor: Colors.white, // 글자색은 하얀색

        padding: EdgeInsets.symmetric(horizontal: 0.01.sh, vertical: 0.01.sw), // 버튼 안의 패딩 설정
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFF4EBDBD), width: 2),
          borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
        ),
      ),
      child: Text(
        btnText, // 버튼에 표시할 텍스트
        style: TextStyle(fontSize: 18.sp), // 텍스트 스타일 설정
      ),
    );
  }
}