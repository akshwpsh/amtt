import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ChatPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//위젯 임포트
import 'package:amtt/widgets/ChatListCard.dart';

class ChatRoomsPage extends StatefulWidget {
  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {

    print('안녕하세요');
    print(currentUser);

    if(currentUser != null) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.06.sw, vertical: 10),
          child: Scaffold(
            backgroundColor: Colors.white,

            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('채팅 목록'),
            ),


            body: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chat_participants')
                  .where('user_id', isEqualTo: _auth.currentUser!.uid)
                  .where('left_at', isNull: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('오류 발생'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('채팅방 없음'),
                  );
                }

                // 채팅 목록 리스트 뷰 빌더
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    String chatRoomId = document['room_id'];

                    // 채팅방 이름을 가져오기 위해 스트림 사용
                    return StreamBuilder<DocumentSnapshot>(
                      stream: _firestore.collection('chat_rooms').doc(chatRoomId).snapshots(),
                      builder: (context, chatRoomSnapshot) {
                        if (chatRoomSnapshot.hasError) {
                          return ListTile(
                            title: Text('채팅방을 불러오던 중 에러가 발생하였습니다.'),
                          );
                        }

                        if (chatRoomSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text('채팅 방 불러오는 중...'),
                          );
                        }

                        // 채팅방 데이터가 있을 때
                        if (chatRoomSnapshot.data != null) {
                          String chatRoomName = chatRoomSnapshot.data!['name'];

                          //TODO : 아래에 실제값 들어가도록 해야함
                          return ChatListcard(
                            userName: chatRoomName,
                            lastChat: '안녕하세요!',
                            profileImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKK2tS5TKEY9O_T4S_YCHES2zZhosMgKWt0A&s',
                            lastTime: '1분전',
                            notiCount: '2',
                            onTap: () => {

                              // 해당 채팅방으로 넘어가는 기능
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(chatRoomId),
                                ),
                              )
                            },
                          );
                        } else {
                          return ListTile(
                            title: Text('Chat room name not found'),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }
    else {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.06.sw, vertical: 10),
          child: Scaffold (

            backgroundColor: Colors.white,

            appBar: AppBar(
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
              backgroundColor: Colors.white,
              title: Text('채팅 목록'),
            ),

            body: Center(
              child: Text(
                '로그인이 필요한 기능입니다'
              ),
            ),

          ),
        ),

      );
    }


  }
}
