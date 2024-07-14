import 'package:flutter/material.dart';

import 'UserEditPage.dart';
import 'ChatPage.dart';
import 'ProductListPage.dart';

class NavigatorPage extends StatefulWidget {

  @override
  NavigatorState createState() => NavigatorState();
}

class NavigatorState extends State<NavigatorPage> {

  // 초기 네비게이션 바 인덱스
  int selectedIndex = 0;

  // 네비게이션 바 페이지 위젯들 리스트
  final List<Widget> NavPage = [
    ProductListPage(),
    ChatPage(),
    UserEditPage(),
  ];

  // 네비게이션 바 아이템 클릭시
  void OnNavTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavPage.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        fixedColor: Color(0xFF4EBDBD),
        unselectedItemColor: Colors.blueGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_books_outlined),
            label: '글목록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '내 정보',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: OnNavTapped,
      ),
    );
  }
}