import 'package:flutter/material.dart';

class UsersdefaultTab extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Widget? trailing;

  const UsersdefaultTab({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap, // 클릭 이벤트
        highlightColor: Colors.grey.withOpacity(0.1), // 길게 누를 때 색상
        splashColor: Colors.grey.withOpacity(0.2), // 탭 했을 때 잉크 효과 색상
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 9),
          child: Row(
            children: [
              // 아이콘 공간
              Icon(
                icon,
                size: 24,
                color: Color(0xff596773),
              ),
              SizedBox(width: 10),

              // 중앙 텍스트 공간
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xff596773),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //트레일링 위젯
              if(trailing != null) trailing!,
              
              // 화살표 아이콘
              if(trailing == null)
                Icon(  
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 30,
                ),
              ],
          ),
        )
      );
  }
}
