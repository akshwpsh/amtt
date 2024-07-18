import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title; //제목
  final String price; //가격
  final String imageUrl; //이미지 경로
  final String userName; //판매자 이름
  final String date; //게시 날짜

  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.userName,
    required this.date,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //제목 텍스트
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),

                    //가격 텍스트
                    Text(
                      price + " 원",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff8ADADA),
                      ),
                    ),
                    SizedBox(height: 8),

                    //추가 정보 공간
                    Row(
                      children: [

                        //게시 날짜
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(width: 12),

                        //판매자 이름
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(width: 12),

                        //TODO : 이 아래는 실제 데이터 여부에 따라 표시되도록, 데이터 없으면 아에 안보이게 해야함

                        //찜 갯수
                        Icon(size: 13, color: Colors.grey,Icons.favorite),
                        Text(
                          ' 0',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(width: 6),

                        //채팅 갯수
                        Icon(size: 13, color: Colors.grey,Icons.chat_bubble_rounded),
                        Text(
                          ' 3',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                      ],
                    )
                  ],
                ),
              ),

              if(imageUrl.isNotEmpty && imageUrl != null)

              //이미지 공간
                Container(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                )


            ],
          ),
        ),
      ),
    );
  }
}
