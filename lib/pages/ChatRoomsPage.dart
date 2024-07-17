import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ChatPage.dart';

class ChatRoomsPage extends StatefulWidget {
  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
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
              child: Text('Something went wrong'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No chat rooms found'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              String chatRoomId = document['room_id'];

              // 채팅방 이름을 가져오기 위해 채팅방 문서 조회
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('chat_rooms').doc(chatRoomId).get(),
                builder: (context, chatRoomSnapshot) {
                  if (chatRoomSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading chat room name'),
                    );
                  }

                  if (chatRoomSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading chat room name...'),
                    );
                  }

                  if (chatRoomSnapshot.data != null) {
                    String chatRoomName = chatRoomSnapshot.data!['name'];
                    return ListTile(
                      title: Text(chatRoomName),
                      onTap: () {
                        // Navigate to the chat room page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(chatRoomId),
                          ),
                        );
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
    );
  }
}
