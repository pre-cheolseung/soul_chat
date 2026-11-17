import 'package:flutter/material.dart';

// 로고를 보여줄 위젯
class Logo extends StatelessWidget {
  final double width;   // 직접 너비를 정의할 경우를 대비한 너비 파라미터
  final double height;   // 직접 높이를 정의할 경우를 대비한 높이 파라미터

  const Logo({
    super.key,
    
    this.width = 200,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/img/logo.png',   // 로고 이미지
          width: width,
          height: height,
        ),
        SizedBox(height: 32.0),
        // 앱 설명 텍스트
        Text(
          'Hi! I am your friend SoulChat!\nTalk with me to build closeness!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}