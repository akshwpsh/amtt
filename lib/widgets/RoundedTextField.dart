import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundedTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const RoundedTextField({Key? key, required this.labelText, required this.controller,
    required this.obscureText, this.inputFormatters, this.keyboardType,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xffF7F8F8),
          border: Border.all(
            color: Color(0xFFBDBDBD),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(color: Color(0xff596773)),
            textAlignVertical: TextAlignVertical.center, // 수직 정렬 유지
            keyboardType: keyboardType,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: labelText,
              border: InputBorder.none,
              isCollapsed: true, // 내부 여백을 없애 텍스트가 중앙에 오도록 함
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // 수직 패딩 추가
            ),
            inputFormatters: inputFormatters,
          ),
        ),
      ),
    );
  }
}