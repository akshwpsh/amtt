import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title; //제목
  final String price; //가격
  final String imageUrl; //이미지 경로
  final String userName;

  const ProductCard({
    Key? key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
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
                      fontSize: 18,
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
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),

                  //추가 정보 공간
                  Row(
                    children: [

                      //판매자 이름
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(width: 12),

                      Icon(size: 13, color: Colors.grey,Icons.favorite),

                      //찜 갯수
                      Text(
                        ' 0',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(width: 3),

                      Icon(size: 13, color: Colors.grey,Icons.chat_bubble_rounded),

                      //채팅 갯수
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

            //이미지 공간
            Container(
              width: 100,
              height: 100,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
