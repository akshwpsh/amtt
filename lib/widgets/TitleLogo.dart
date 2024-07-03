import 'package:flutter/material.dart';

class TitleLogo extends StatelessWidget {
  const TitleLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child:Text(
            '대학장터',
            style: TextStyle(color: Color(0xFF4EBDBD), fontSize: 40, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child:Text(
            '우리들만의 작은 장터',
            style: TextStyle(color: Color(0xFF1111111), fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}