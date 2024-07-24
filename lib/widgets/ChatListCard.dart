import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ChatListcard extends StatelessWidget {
  final String userName; // 상대방 이름
  final String lastChat; // 가장 최근 대화 내용
  final String profileImageUrl; // 상대방 프로필 이미지
  final String lastTime; // 최근 대화일시
  final String notiCount; // 알림 갯수 - 안 읽은 대화 갯수

  final VoidCallback? onTap;

  const ChatListcard({
    Key? key,
    required this.userName,
    required this.lastChat,
    required this.profileImageUrl,
    required this.lastTime,
    required this.notiCount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell( //카드 색상 효과 위한 위젯
      onTap: onTap, //클릭 이벤트
      highlightColor: Colors.grey.withOpacity(0.1), //길게 누를 때 색상
      splashColor: Colors.grey.withOpacity(0.2), //탭 했을 때 잉크 효과 색상
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide( // 위 테두리
              color: Color(0xffF7F8F8),
              width: 1.0,
            ),
            bottom: BorderSide( // 아래 테두리
              color: Color(0xffF7F8F8),
              width: 1.0,
            ),
          ),
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 프로필 이미지 공간
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: profileImageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(profileImageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: profileImageUrl.isEmpty
                    ? Icon(
                  Icons.account_circle_rounded,
                  size: 60,
                  color: Colors.grey,
                )
                    : null,
              ),

              SizedBox(width: 10),

              // 텍스트 데이터 공간
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상대방 이름 텍스트
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 8),

                    // 최근 채팅 내용 텍스트
                    Text(
                      lastChat,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10),

              // 최근 채팅 시간 공간
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lastTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 3,),

                  // 채팅 안 읽은 거 알림 갯수
                  if (notiCount.isNotEmpty && int.parse(notiCount) > 0) //내용이 비어있지 않고 0보다 크면
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notiCount,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}