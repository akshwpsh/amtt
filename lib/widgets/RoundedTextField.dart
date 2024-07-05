import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundedTextField extends StatelessWidget {
  final String labelText; //labelText 내용 받는 변수
  final TextEditingController controller; //텍스트 컨트롤러
  final bool obscureText; //내용 숨기기 설정(비밀번호)
  const RoundedTextField({Key? key, required this.labelText, required this.controller, required this.obscureText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0), // 양옆 패딩
      child: Container(
        height: 0.06.sh,
        decoration: BoxDecoration(
          color: Colors.grey[300], // 회색 배경색
          borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: labelText,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0), //내부 패딩
          ),
        ),
      ),
    );
  }
}