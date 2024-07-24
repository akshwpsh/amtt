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

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatPage extends StatelessWidget {
  final String chatRoomId;
  final TextEditingController _controller = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  ChatPage(this.chatRoomId);

  @override
  Widget build(BuildContext context) {

    // 바텀시트 보이게 하는 메서드
    void _showBottomSheet() {
      showModalBottomSheet(
          context: context,
        builder: (BuildContext context) {
          // 키보드 높이를 가져옵니다.
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

          print('키보드 높이 : ');
          print(keyboardHeight);

          // BottomSheet의 높이를 키보드 높이 또는 최소 높이 중 큰 값으로 설정합니다.
          final sheetHeight = 200.0;
          return Container(
            height: sheetHeight,
            child: BottomSheetContent(imagePressed: _sendImages),
          );
        },
      );
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.06.sw, vertical: 10),
        child: Scaffold(
          backgroundColor: Colors.white,

          //앱바
          appBar: AppBar(
            scrolledUnderElevation: 0, // 스크롤시 색상 변경 방지
            backgroundColor: Colors.white,
            title: Text('채팅방'),
            actions: [

              // 채팅방 나가기 버튼
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

              SizedBox(height: 10,),

              //게시글 확인하러 가기 공간
              Material(
                color: Color(0xFFDCF2F2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => {
                    
                    //TODO : 여기에 게시글 확인하러 가는 코드 넣어야함
                    
                  },
                  highlightColor: Colors.grey.withOpacity(0.1), //길게 누를 때 색상
                  splashColor: Colors.grey.withOpacity(0.2), //탭 했을 때 잉크 효과 색상
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    child: Center(
                      child: Text(
                        '게시글 확인하러 가기',
                        style: TextStyle(
                          color: Color(0xFF4EBDBD), // 텍스트 색
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15,),


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

                    // 메시지 리스트 빌더
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

                          // 채팅 메시지 공간
                          child: Column(
                            crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),

                                //박스 데코레이션 (색상, 둥근 테두리)
                                decoration: BoxDecoration(
                                  color: isMe ? Color(0xff4EBDBD): Colors.grey[300],
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

                                    // 채팅 유저명 공간
                                    Text(
                                      message['sender'],
                                      style: TextStyle(
                                          color: isMe ? Colors.black54 : Colors.black54,
                                          fontSize: 12),
                                    ),
                                    SizedBox(width: 10),

                                    // 채팅 시간 표시 공간
                                    Text(
                                      time,
                                      style: TextStyle(
                                          color: isMe ? Colors.black54 : Colors.black54,
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

              SizedBox(height: 25,),


              //채팅 입력 바 공간
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    children: [
                      // 맨 왼쪽 버튼 변경 (플러스 기호)
                      IconButton(
                        icon: Icon(Icons.add), // 플러스 기호 아이콘
                        onPressed: _showBottomSheet,
                      ),

                      SizedBox(width: 5,),

                      // 메시지 입력창
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (value) {
                            _sendMessage();
                          },
                          decoration: InputDecoration(
                            hintText: '메시지 입력',
                            // 둥근 모서리 및 초록색 테두리 추가
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12), // 원하는 곡률 조절
                              borderSide: BorderSide(
                                width: 2, // 테두리 두께 조절
                              ),
                            ),
                            focusedBorder: OutlineInputBorder( // 활성화 시 테두리 설정
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xff4EBDBD), // 활성화 시 테두리 색상
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 10,),

                      //메시지 전송버튼
                      Expanded(
                          flex: 1,
                        child: ElevatedButton(
                          onPressed: _sendMessage,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(55),
                            foregroundColor: Colors.white, backgroundColor: Color(0xFF4EBDBD), // 글자색은 하얀색
                            padding: EdgeInsets.symmetric(horizontal: 0.01.sh, vertical: 0.01.sw), // 버튼 안의 패딩 설정
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
                            ),
                          ),
                          child: Text(
                            '전송', // 버튼에 표시할 텍스트
                            style: TextStyle(fontSize: 20), // 텍스트 스타일 설정
                          ),
                        )
                      ),

                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }


  // 메시지 보내는 메서드
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

  // 이미지 보내는 메서드
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


// 하단에서 올라오는 추가 기능 다이얼로그창
class BottomSheetContent extends StatelessWidget {
  final VoidCallback imagePressed; // 이미지 클릭 이벤트
  //final VoidCallback mapPressed;

  const BottomSheetContent({super.key, required this.imagePressed});

  @override
  Widget build(BuildContext context) {


    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(0.03.sh),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 상단바 공간
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                '추가 기능',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 48), // To balance the back button on the left
            ],
          ),


          //아이템 버튼 공간
          SizedBox(height: 26),

          // 아이템 버튼 공간
          Wrap(
            spacing: 24, // 버튼 간 간격
            runSpacing: 16, // 행 간 간격
            children: [

              Column(

                children: [


                  //이미지 전송 버튼
                  ElevatedButton(
                    onPressed: () {
                      imagePressed();
                      print("이거 실행");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff4EBDBD),
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                    ),
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  SizedBox(height: 5,),

                  Text('이미지 전송'),
                ],

              ),


              Column(
                children: [

                  // 지도 버튼 -- 미구현시 삭제
                  ElevatedButton(
                    onPressed: () {
                      // 버튼 클릭 시 처리 코드
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff4EBDBD),
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                    ),
                    child: Icon(
                      Icons.map,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  SizedBox(height: 5,),

                  Text('내 위치 전송'),
                ],
              ),

            ],
          ),


        ],
      ),
    );
  }
}
