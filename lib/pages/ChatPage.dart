import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';


class ChatPage extends StatefulWidget {

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<ChatPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('채팅 목록'),
      ),
      body: Container(

        child: Text('채팅 페이지입ㄴ디ㅏ.'),

      ),

    );
  }
}

