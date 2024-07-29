import 'package:amtt/Service/FirebaseService.dart';
import 'package:amtt/Service/PushNotification.dart';
import 'package:amtt/pages/UnivSelectPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'pages/MainPage.dart';
import 'pages/NavigatePage.dart';
import 'pages/ProductDetailPage.dart';
import 'pages/ChatPage.dart';

import 'pages/LoginPage.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//푸시 알림 메시지와 상호작용을 정의합니다.
Future<void> setupInteractedMessage() async {
  //앱이 종료된 상태에서 열릴 때 getInitialMessage 호출
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
}
//FCM에서 전송한 data를 처리합니다. /message 페이지로 이동하면서 해당 데이터를 화면에 보여줍니다.
void _handleMessage(RemoteMessage message) {
  Future.delayed(const Duration(seconds: 1), () {
    print("id: ${message.data['id']}");
    String type = message.data['type'];
    if(type == 'message')
      navigatorKey.currentState!.pushNamed('/message', arguments: message.data['id']);
    else if(type == 'keyword')
      navigatorKey.currentState!.pushNamed('/post', arguments: message.data['id']);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());


  PushNotification.localNotiInit();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  final vapIdKey = await FirebaseService().getVapidKey();
  final token = await messaging.getToken(vapidKey: vapIdKey);
  print('Token: $token');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      PushNotification.showSimpleNotification(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? 'You have received a new message.',
        payload: "type=" + message.data['type'] + "&id=" + message.data['id'] ?? '',
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}



class MyApp extends StatelessWidget {

  User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Padding(
          //전체 패딩 적용 경우 생각해 추가한 패딩
          padding: EdgeInsets.all(0.00.sw),
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Flutter Auth Demo',
            debugShowCheckedModeBanner: false, //디버그 배너 끄기
            theme: ThemeData(
              primaryColor:   Color(0xff4EBDBD),
              //텍스트 필드 선택 되었을 때의 커서 색상 설정
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Color(0xff4EBDBD), // 커서 색상 설정선택 핸들 색상 설정
              ),
            ),
            home: currentUser == null
                ? UnivSelectPage() // 로그인 페이지를 보여주는 경우
                : FutureBuilder<String>(
              future: getUserUniversity(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // 로딩 인디케이터
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return NavigatePage(university: snapshot.data!);
                } else {
                  return Center(child: Text('No university found.'));
                }
              },
            ),
            onGenerateRoute: (RouteSettings settings) {
              if (settings.name == '/post') {
                final id = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) {
                    return ProductDetailPage(postId: id);
                  },
                );
              }
              if (settings.name == '/message') {
                final id = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) {
                    return ChatPage(id);
                  },
                );
              }
              // 다른 라우트에 대한 처리가 필요하면 여기에 추가
              return null; // 일치하는 라우트가 없을 경우 null 반환
            },
          ),
        );
      },
    );
  }

  Future<String> getUserUniversity(String uid) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return userData['school'] as String;
  }
}
