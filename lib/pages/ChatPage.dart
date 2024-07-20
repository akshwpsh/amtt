import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:amtt/Service/FirebaseService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatPage extends StatelessWidget {
  final String chatRoomId;
  final TextEditingController _controller = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  ChatPage(this.chatRoomId);

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
              }),
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
                    var time = timestamp != null
                        ? DateFormat('HH:mm').format(timestamp.toDate())
                        : 'N/A';

                    Widget messageWidget;
                    if (message['type'] == 'text') {
                      messageWidget = Text(
                        message['text'],
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black),
                      );
                    } else if (message['type'] == 'image') {
                      messageWidget = Image.network(message['imageUrl']);
                    } else if (message['type'] == 'images') {
                      List<dynamic> imageUrls = message['imageUrls'];
                      messageWidget = Column(
                        children: imageUrls
                            .map((url) => Image.network(url))
                            .toList(),
                      );
                    } else {
                      messageWidget = SizedBox.shrink(); // 미지정 유형
                    }

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: messageWidget,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment:
                              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                Text(
                                  message['sender'],
                                  style: TextStyle(
                                      color: isMe ? Colors.white70 : Colors.black54,
                                      fontSize: 12),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  time,
                                  style: TextStyle(
                                      color: isMe ? Colors.white70 : Colors.black54,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _sendImages,
                ),
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
        'type': 'text',
      });
      _sendNotification(_controller.text);
      _controller.clear();
    }
  }

  Future<void> _sendImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<String> imageUrls = [];
      for (var pickedFile in pickedFiles) {
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${FirebaseAuth.instance.currentUser!.uid}.png';

        if (kIsWeb) {
          // Web specific code
          Uint8List imageData = await pickedFile.readAsBytes();
          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child('chat_images')
              .child(chatRoomId)
              .child(fileName)
              .putData(imageData);
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          String imageUrl = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        } else {
          // Mobile specific code
          io.File imageFile = io.File(pickedFile.path);
          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child('chat_images')
              .child(chatRoomId)
              .child(fileName)
              .putFile(imageFile);
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          String imageUrl = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }

      FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'imageUrls': imageUrls,
        'sender': FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown',
        'senderId': userId, // 사용자 ID 추가
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'images',
      });
      _sendNotification('여러 이미지를 보냈습니다.');
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
