import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addKeyword(String keyword) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty && keyword.isNotEmpty) {
      await _firestore.collection('keywords').add({
        'uid': uid,
        'keyword': keyword,
      });
    }
  }

  Future<void> saveMessageToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty && token != null) {
      // Firestore에서 동일한 uid와 token을 가진 문서가 있는지 확인
      final querySnapshot = await _firestore.collection('MessageTokens')
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
    String currentUid = FirebaseAuth.instance.currentUser!.uid;
    // 1. 키워드 컬렉션에서 모든 문서를 가져온다.
    QuerySnapshot keywordSnapshot = await _firestore.collection('keywords').get();

    // 2. 제목에 포함된 키워드를 찾는다.
    for (var doc in keywordSnapshot.docs) {

      String keyword = doc['keyword'];
      String uid = doc['uid'];
      // 3. 현재 로그인한 사용자는 제외
      if ( uid != currentUid && title.contains(keyword)) {
        // 4. 해당 키워드를 가진 사용자의 메시지 토큰을 가져온다.
        QuerySnapshot tokenSnapshot = await _firestore.collection('MessageTokens')
            .where('uid', isEqualTo: uid)
            .get();

        // 5. 메시지 토큰을 사용하여 알림을 보낸다.
        for (var tokenDoc in tokenSnapshot.docs) {
          String token = tokenDoc['token'];
          print ('send to $uid, $token');
          await send(token, title, "키워드를 포함한 게시글이 등록됐습니다.", "keyword", productId);
        }
      }
    }
  }
  static Future<void> send(String token, String title, String body, String type, String id) async {
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
        'data': { //payload 데이터 구성
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
     print(
          'FCM notification sent with status code: ${response.statusCode}');
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
}






