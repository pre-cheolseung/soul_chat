import 'dart:io';

import 'package:flutter/material.dart';

import 'package:soul_chat/utils/app_snack_bar.dart';
import 'package:soul_chat/widgets/full_screen_image_viewer.dart';

import 'package:open_filex/open_filex.dart';   // 기본 뷰어 앱 연결 패키지

// 첨부파일(이미지 vs PDF 등 문서) 렌더링 위젯
class MessageAttachment extends StatelessWidget {
  final String filePath;
  final String? mimeType;
  final Color textColor;

  const MessageAttachment({
    super.key,

    required this.filePath,
    this.mimeType,
    required this.textColor,
  });

  // 파일 확장자가 이미지인지 판별
  bool _isImage() {
    if (mimeType != null && mimeType!.startsWith('image/')) return true;

    final lower = filePath.toLowerCase();

    return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);

    // 원본 파일이 기기에서 삭제된 경우 안전하게 예외 처리
    if (!file.existsSync()) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 18.0,
              color: textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6.0),
            Text(
              'This file has been deleted',
              style: TextStyle(
                fontSize: 13.0,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // 이미지인 경우: 둥근 모서리 이미지 출력 (탭하면 전체 화면 뷰어로 부드럽게 확장)
    if (_isImage()) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => FullScreenImageViewer(
                imageFile: file,
                heroTag: filePath,   // 파일 경로를 고유 태그로 사용
              ),
            ),
          );
        },
        child: Hero(
          tag: filePath,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: ConstrainedBox(
              // 이미지가 너무 길어서 스크롤 계산을 망가뜨리지 않도록 최대 높이 제한
              constraints: const BoxConstraints(
                maxHeight: 260.0,
                maxWidth: 220.0,
              ),
              child: Image.file(
                file,
                width: 220.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    // PDF 및 일반 문서인 경우: 파일 아이콘 + 파일명 카드 출력 (탭하면 기기 기본 뷰어 앱으로 연결)
    final fileName = filePath.split('/').last;

    return GestureDetector(
      onTap: () async {
        final result = await OpenFilex.open(filePath);

        // 기기에 해당 파일을 열 수 있는 앱이 없는 경우 안내 스낵바 표시
        if (result.type != ResultType.done && context.mounted) {
          AppSnackBar.showError(context, 'Cannot open file : ${result.message}');   // 파일 열기 실패 에러 알림
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              size: 22.0,
              color: textColor,
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 6.0),
            // 클릭 가능한 문서임을 알려주는 열기 아이콘 추가
            Icon(
              Icons.open_in_new_rounded,
              size: 15.0,
              color: textColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}