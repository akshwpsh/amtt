import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // 시간 형식을 위해 필요
import 'package:amtt/Service/FirebaseService.dart';

class ChatPage extends StatelessWidget {
  final String chatRoomId;

  ChatPage(this.chatRoomId);

  final TextEditingController _controller = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseService().leaveChatRoom(chatRoomId);
              Navigator.pop(context);
            }
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == userId;
                    var timestamp = message['timestamp'] as Timestamp?;
                    var time = timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : 'N/A';
                    return Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Text(
                                message['sender'],
                                style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 12),
                              ),
                              SizedBox(width: 10),
                              Text(
                                time,
                                style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': _controller.text,
        'sender': FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown',
        'senderId': userId, // 사용자 ID 추가
        'timestamp': FieldValue.serverTimestamp(),
      });
      _sendNotification(_controller.text);
      _controller.clear();
    }
  }

  void _sendNotification(String message) async {
    final otherUserId = await getOtherUserId(chatRoomId);
    FirebaseService().notifyChat(otherUserId, chatRoomId, message);

  }

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

}
