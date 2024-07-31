import 'package:amtt/pages/UserPage.dart';
import 'package:flutter/material.dart';

import 'ChatRoomsPage.dart';
import 'ProductListPage.dart';

class NavigatePage extends StatefulWidget {
  final String university;

  NavigatePage({Key? key, required this.university}) : super(key: key);

  @override
  NavigateState createState() => NavigateState();
}

class NavigateState extends State<NavigatePage> {
  // 초기 네비게이션 바 인덱스
  int selectedIndex = 0;

  // 뒤로가기 버튼 클릭 횟수
  int backButtonPressCount = 0;

  // 네비게이션 바 아이템 클릭시
  void OnNavTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // 앱 종료 여부를 확인하는 메서드
  Future<bool> onWillPop() async {
    if (backButtonPressCount == 1) {
      return true; // 앱 종료
    } else {
      backButtonPressCount++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('한번 더 누르시면 앱이 종료됩니다'),
          duration: Duration(seconds: 3),
        ),
      );
      // 2초 후에 클릭 횟수 초기화
      Future.delayed(Duration(seconds: 2), () {
        backButtonPressCount = 0;
      });
      return false; // 앱 종료 방지
    }
  }

  @override
  Widget build(BuildContext context) {
    print("입력된 대학은");
    print(widget.university);

    // 네비게이션 바 페이지 위젯들 리스트
    final List<Widget> NavPage = [
      ProductListPage(university: widget.university),
      ChatRoomsPage(),
      UserPage(),
    ];

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
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
      ),
    );
  }
}
