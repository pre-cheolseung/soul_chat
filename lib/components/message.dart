import 'dart:io';

import 'package:flutter/material.dart';

import 'package:soul_chat/components/point_notification.dart';
import 'package:soul_chat/widget/full_screen_image_viewer.dart';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';   // 마크다운 패키지

class Message extends StatelessWidget {
  final bool alignLeft;
  final String message;
  final int? point;
  final String? filePath;   // 첨부파일 경로
  final String? mimeType;   // 첨부파일 MIME 타입


  const Message({
    super.key,

    this.alignLeft = true,
    required this.message,
    this.point,
    this.filePath,
    this.mimeType,
  });

  // 파일 확장자가 이미지인지 판별하는 함수
  bool _isImage() {
    if (mimeType != null && mimeType!.startsWith('image/')) return true;
    
    if (filePath != null) {
      final lower = filePath!.toLowerCase();
      return lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final alignment = alignLeft ? Alignment.centerLeft : Alignment.centerRight;   // alignLeft 기준으로 Alignment 프로퍼티 생성
    // 내 메시지(왼쪽 정렬)는 포인트 컬러
    final bgColor = alignLeft ? const Color(0xFFF5F6F8) : const Color(0xFFF2EEFF);
    final textColor = alignLeft ? const Color(0xFF1A1A1A) : const Color(0xFF2D2254);
    final borderColor = alignLeft ? const Color(0xFFE8EAEF) : const Color(0xFFE2D9FF);
    final hasFile = filePath != null && filePath!.isNotEmpty;
    final hasText = message.trim().isNotEmpty;

    return Column(
      children: [
        Align(
          alignment: alignment,
          child: Container(
            // 이미지가 너무 커져서 화면을 다 덮지 않도록 최대 가로 폭 제한
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            // 말풍선 꼬리 느낌을 주는 비대칭 모서리
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(alignLeft ? 4.0 : 20.0),
                topRight: Radius.circular(alignLeft ? 20.0 : 4.0),
                bottomLeft: const Radius.circular(20.0),
                bottomRight: const Radius.circular(20.0),
              ),
              border: Border.all(color: borderColor, width: 1.0),
              // 은은한 입체감 그림자
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              // 여러 줄 텍스트도 답답하지 않은 여유로운 패딩
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 14.0,
              ),
              // AI 메시지(alignLeft == true)일 때만 마크다운 렌더링 적용
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 첨부파일이 있는 경우 상단에 먼저 렌더링
                  if (hasFile) _buildAttachment(context, filePath!, textColor),

                  // 파일과 텍스트가 둘 다 있을 때만 중간 여백 추가
                  if (hasFile && hasText) const SizedBox(height: 8.0),

                  // 텍스트가 있는 경우 렌더링
                  if (hasText)
                    alignLeft
                      ? MarkdownBody(
                          data: message,
                          fitContent: true,   // 짧은 문장일 때 말풍선이 불필요하게 넓어지지 않게 설정
                          selectable: true,   // AI 답변 텍스트를 길게 눌러 복사할 수 있게 허용
                          styleSheet: MarkdownStyleSheet(
                            // 문단과 문단 사이의 간격
                              blockSpacing: 10.0,
                            // 일반 본문 스타일
                            p: TextStyle(
                              color: textColor,
                              fontSize: 15.5,
                              height: 1.5,   // 줄 간격을 1.5로 넓혀 가독성 향상
                              letterSpacing: -0.2,
                            ),
                            // **굵은 글씨** 스타일
                            strong: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            // *기울임* 스타일
                            em: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF4A4A4A),
                            ),
                            // 제목(#, ##, ###) 스타일
                            h1: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.4
                            ),
                            h2: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.4
                            ),
                            h3: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              height: 1.4
                            ),
                            // 목록(-, 1.) 점/숫자 스타일
                            listBullet: TextStyle(
                              color: textColor,
                              fontSize: 15.5,
                            ),
                            listIndent: 16.0,
                            // 인용구(> ) 스타일
                            blockquoteDecoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 3.0
                                ),
                              ),
                            ),
                            blockquotePadding: const EdgeInsets.only(
                              left: 12.0,
                              top: 4.0,
                              bottom: 4.0
                            ),
                            // `인라인 코드` 스타일
                            code: const TextStyle(
                              backgroundColor: Color(0xFFE6E8EC),
                              color: Color(0xFFD6336C),   // 포인트 컬러로 코드 강조
                              fontFamily: 'monospace',
                              fontSize: 13.5,
                            ),
                            // ```코드 블록``` 스타일
                            codeblockDecoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            codeblockPadding: const EdgeInsets.all(14.0),
                          ),
                        )
                      : Text(
                          message,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15.5,
                            height: 1.45,
                            letterSpacing: -0.2,
                          ),
                        ),
                ],
              )
            ),
          ),
        ),
        // point가 입력됐을 때만 PointNotification 위젯을 화면에 출력
        if (point != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Align(
              alignment: alignment,
              child: PointNotification(point: point!),
            ),
          ),
      ],
    );
  }

  // 첨부파일(이미지 vs PDF 등 문서) 렌더링 위젯
  Widget _buildAttachment(BuildContext context, String path, Color textColor) {
    final file = File(path);

    // 원본 파일이 기기에서 삭제된 경우 안전하게 예외 처리
    if (!file.existsSync()) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 8.0
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
              color: textColor.withValues(alpha: 0.6)
            ),
            const SizedBox(width: 6.0),
            Text(
              'This file has been deleted',
              style: TextStyle(
                fontSize: 13.0,
                color: textColor.withValues(alpha: 0.6)
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
                heroTag: path,   // 파일 경로를 고유 태그로 사용
              ),
            ),
          );
        },
        child: Hero(
          tag: path,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.file(
              file,
              width: 220.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    // PDF 및 일반 문서인 경우: 파일 아이콘 + 파일명 카드 출력
    final fileName = path.split('/').last;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 10.0
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
            color: textColor
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
        ],
      ),
    );
  }
}