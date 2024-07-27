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

  // 상대방 유저 ID 가져오는 메서드
  Future<String> getOtherUserId(String chatRoomId) async {
    QuerySnapshot participantsSnapshot = await FirebaseFirestore.instance
        .collection('chat_participants')
        .where('room_id', isEqualTo: chatRoomId)
        .get();

    String userId = FirebaseAuth.instance.currentUser!.uid;

    for (DocumentSnapshot participant in participantsSnapshot.docs) {
      if (participant.get('user_id') != userId) {
        return participant.get('user_id');
      }
    }

    return '';
  }

  // 상대방 프로필 이미지 가져오는 메서드
  Future<String?> getOtehrUserImg(String chatRoomId) async {

    final userId = await getOtherUserId(chatRoomId);
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    String? profileImageUrl = userData['imageUrl']; // 프로필 이미지 URL

    return profileImageUrl;

  }

  // 가장 최근 메시지 가져오는 메서드
  Future<Map<String, dynamic>?> getLastMessage(String chatRoomId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();


  }

  // 현재 시간과 지금 시간 비교해서 메시지 지난시간 양식 반환 메서드
  String getRelativeTime(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}년 전';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }


  @override
  Widget build(BuildContext context) {

    if(currentUser != null) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(0.04.sw),
          child: Scaffold(
            backgroundColor: Colors.white,

            appBar: AppBar(
              scrolledUnderElevation: 0, //스크롤 해도 색상 바뀌지 않게
              automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
              backgroundColor: Colors.white,
              titleSpacing: 0,
              title: Text(
                '채팅 목록',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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


                          return FutureBuilder(
                              future: getOtehrUserImg(chatRoomId),
                              builder: (context, profileImgSnapshot) {
                                return FutureBuilder<Map<String, dynamic>?>(
                                    future: getLastMessage(chatRoomId),
                                    builder: (context, lastMessageSnapshot) {
                                      if (profileImgSnapshot.connectionState == ConnectionState.done &&
    lastMessageSnapshot.connectionState == ConnectionState.done) {

                                        String lastMessageText = '메시지 없음';
                                        String lastMessageTime = '';

                                        if (lastMessageSnapshot.data != null) {
                                          lastMessageText = lastMessageSnapshot.data!['text'] as String? ?? '메시지 없음';
                                          Timestamp? timestamp = lastMessageSnapshot.data!['timestamp'] as Timestamp?;
                                          if (timestamp != null) {
                                            DateTime messageTime = timestamp.toDate();
                                            lastMessageTime = getRelativeTime(messageTime);
                                          }
                                        }

                                        return ChatListcard(
                                    userName: chatRoomName,
                                    lastChat: lastMessageText,
                                    profileImageUrl: profileImgSnapshot.data ?? '',
                                    lastTime: lastMessageTime,
                                    notiCount: '0',
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

                                }
                                else {

                                  return ListTile(
                                    title: Text('채팅방 찾는중'),
                                  );

                                }

                              });

                        });


                        }else {
                          return ListTile(
                            title: Text('채팅방 찾는중'),
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
