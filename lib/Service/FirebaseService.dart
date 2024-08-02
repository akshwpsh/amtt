import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessageToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty && token != null) {
      // Firestore에서 동일한 uid와 token을 가진 문서가 있는지 확인
      final querySnapshot = await _firestore
          .collection('MessageTokens')
          .where('uid', isEqualTo: uid)
          .where('token', isEqualTo: token)
          .get();

      // 동일한 uid와 token을 가진 문서가 없을 경우에만 새 문서 추가
      if (querySnapshot.docs.isEmpty) {
        await _firestore.collection('MessageTokens').add({
          'token': token,
          'uid': uid,
        });
      }
    }
  }

  Future<void> notifyUsersByTitle(String title, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    bool _notiEnabled = prefs.getBool('notificationEnabled') ?? true;
    if (!_notiEnabled) return;

    String currentUid = FirebaseAuth.instance.currentUser!.uid;
    // 1. 키워드 컬렉션에서 모든 문서를 가져온다.
    QuerySnapshot keywordSnapshot =
        await _firestore.collection('keywords').get();

    // 2. 제목에 포함된 키워드를 찾는다.
    for (var doc in keywordSnapshot.docs) {
      String keyword = doc['keyword'];
      String uid = doc['uid'];
      // 3. 현재 로그인한 사용자는 제외
      if (uid != currentUid && title.contains(keyword)) {
        // 4. 해당 키워드를 가진 사용자의 메시지 토큰을 가져온다.
        QuerySnapshot tokenSnapshot = await _firestore
            .collection('MessageTokens')
            .where('uid', isEqualTo: uid)
            .get();

        // 5. 메시지 토큰을 사용하여 알림을 보낸다.
        for (var tokenDoc in tokenSnapshot.docs) {
          String token = tokenDoc['token'];
          print('send to $uid, $token');
          await send(
              token, title, "키워드를 포함한 게시글이 등록됐습니다.", "keyword", productId);
        }
      }
    }
  }

  Future<void> notifyChat(
      String toUid, String messageId, String message) async {

    final prefs = await SharedPreferences.getInstance();
    bool _notiEnabled = prefs.getBool('notificationEnabled') ?? true;
    if (!_notiEnabled) return;    
    
    if (toUid.isNotEmpty) {
      QuerySnapshot tokenSnapshot = await _firestore
          .collection('MessageTokens')
          .where('uid', isEqualTo: toUid)
          .get();
      for (var tokenDoc in tokenSnapshot.docs) {
        String token = tokenDoc['token'];
        print('send to $toUid, $token');
        await send(token, "새로운 메시지가 도착했습니다.", message, "message", messageId);
      }
    }
  }

  static Future<void> send(
      String token, String title, String body, String type, String id) async {
    final jsonCredentials =
        await rootBundle.loadString('assets/secret_key.json');
    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);
    final fcmurl = await FirebaseService().getFCMUrl();
    final client = await auth.clientViaServiceAccount(
      creds,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    final notificationData = {
      'message': {
        'token': token, //기기 토큰
        'data': {
          //payload 데이터 구성
          'type': type,
          'id': id,
        },

        'notification': {
          'title': title, //푸시 알림 제목
          'body': body, //푸시 알림 내용
        }
      },
    };
    final response = await client.post(
      Uri.parse(fcmurl),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 200) {
      print('FCM notification sent with status code: ${response.statusCode}');
    } else {
      print(
          '${response.statusCode} , ${response.reasonPhrase} , ${response.body}');
    }
  }

  Future<String> getFCMUrl() async {
    final String response = await rootBundle.loadString('assets/secret.json');
    final data = await json.decode(response);
    return data['fcm_url'];
  }

  Future<String> getVapidKey() async {
    final String response = await rootBundle.loadString('assets/secret.json');
    final data = await json.decode(response);
    return data['vapid_key'];
  }

  Future<String> createChatRoom(
      String otherUserId, String productId, String roomName) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // 1. 채팅방 문서 생성
    DocumentReference chatRoomRef =
        await FirebaseFirestore.instance.collection('chat_rooms').add({
      'name': roomName,
      'last_updated': FieldValue.serverTimestamp(),
      'product_id': productId,
    });

    // 2. 참여자 문서 생성
    await FirebaseFirestore.instance
        .collection('chat_participants')
        .doc('${chatRoomRef.id}-$userId')
        .set({
      'product_id': productId,
      'room_id': chatRoomRef.id,
      'user_id': userId,
      'joined_at': FieldValue.serverTimestamp(),
      'left_at': null,
    });

    await FirebaseFirestore.instance
        .collection('chat_participants')
        .doc('${chatRoomRef.id}-$otherUserId')
        .set({
      'product_id': productId,
      'room_id': chatRoomRef.id,
      'user_id': otherUserId,
      'joined_at': FieldValue.serverTimestamp(),
      'left_at': null,
    });

    return chatRoomRef.id;
  }

  Future<void> leaveChatRoom(String chatRoomId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // 1. 참여자 문서 업데이트
    await FirebaseFirestore.instance
        .collection('chat_participants')
        .doc('$chatRoomId-$userId')
        .update({
      'left_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejoinChatRoom(String chatRoomId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // 1. 참여자 문서 확인
    DocumentSnapshot participantDoc = await FirebaseFirestore.instance
        .collection('chat_participants')
        .doc('$chatRoomId-$userId')
        .get();

    if (!participantDoc.exists || participantDoc['left_at'] != null) {
      // 2. 채팅방 참여
      await FirebaseFirestore.instance
          .collection('chat_participants')
          .doc('$chatRoomId-$userId')
          .set({
        'product_id': participantDoc['product_id'],
        'room_id': chatRoomId,
        'user_id': userId,
        'joined_at': FieldValue.serverTimestamp(),
        'left_at': null,
      });
    }
  }

  Future<String?> getExistingChatRoomId(
      String otherUserId, String productId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // 1. 사용자와 특정 제품에 대한 모든 채팅방 조회
    QuerySnapshot userChatRoomsSnapshot = await FirebaseFirestore.instance
        .collection('chat_participants')
        .where('user_id', isEqualTo: userId)
        .where('product_id', isEqualTo: productId)
        .get();

    for (QueryDocumentSnapshot userChatDoc in userChatRoomsSnapshot.docs) {
      String chatRoomId = userChatDoc['room_id'];

      // 2. 해당 채팅방에 다른 사용자가 참여하고 있는지 확인
      QuerySnapshot otherUserChatRoomsSnapshot = await FirebaseFirestore
          .instance
          .collection('chat_participants')
          .where('room_id', isEqualTo: chatRoomId)
          .where('user_id', isEqualTo: otherUserId)
          .get();

      if (otherUserChatRoomsSnapshot.docs.isNotEmpty) {
        print('Existing chat room found: $chatRoomId');
        return chatRoomId;
      }
    }

    // 해당 조건을 만족하는 채팅방이 없는 경우 null 반환
    print('No existing chat room found');
    return null;
  }
}
