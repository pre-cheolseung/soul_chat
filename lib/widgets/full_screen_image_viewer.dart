import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final File imageFile;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,

    required this.imageFile,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,   // 사진이 돋보이는 검은 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 28.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,   // 앱바 뒤까지 이미지가 꽉 차게 확장
      body: GestureDetector(
        // 빈 검은 배경을 탭하면 닫히도록 설정
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          // 두 손가락으로 확대/축소(0.8배 ~ 4.0배) 및 드래그 이동 지원
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Hero(
              tag: heroTag,   // 말풍선 이미지와 연결되는 고유 태그
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}