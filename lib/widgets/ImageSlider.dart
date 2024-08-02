import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ImageSliderWithIndicator extends StatefulWidget {
  final List<dynamic> imageUrls; //이미지 주소들 받는 리스트

  ImageSliderWithIndicator({required this.imageUrls});

  @override
  _ImageSliderWithIndicatorState createState() => _ImageSliderWithIndicatorState();
}

class _ImageSliderWithIndicatorState extends State<ImageSliderWithIndicator> {
  int currentPage = 0;
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xff767676),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 0.3.sh, //이미지 높이
            //페이지 뷰 빌더
            child: PageView.builder(
              controller: pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      //이미지 공간
                      child: Image.network(
                        widget.imageUrls[index],
                        // 이미지 꽉차게
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 10),

        //이미지 슬라이더 인디케이터 공간
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
                (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4), //인디케이터 사이 마
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                //현재 페이지 맞게 색상 변경
                color: currentPage == index
                    ? Color(0xff4EBDBD)
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}