import 'package:flutter/material.dart';

import 'package:soul_chat/components/point_notification.dart';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';   // 마크다운 패키지

class Message extends StatelessWidget {
  final bool alignLeft;
  final String message;
  final int? point;

  const Message({
    super.key,

    this.alignLeft = true,
    this.point,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = alignLeft ? Alignment.centerLeft : Alignment.centerRight;   // alignLeft 기준으로 Alignment 프로퍼티 생성
    // 내 메시지(왼쪽 정렬)는 포인트 컬러
    final bgColor = alignLeft ? const Color(0xFFF5F6F8) : const Color(0xFFF2EEFF);
    final textColor = alignLeft ? const Color(0xFF1A1A1A) : const Color(0xFF2D2254);
    final borderColor = alignLeft ? const Color(0xFFE8EAEF) : const Color(0xFFE2D9FF);

    return Column(
      children: [
        Align(
          alignment: alignment,
          child: Container(
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
                horizontal: 16.0,
              ),
              // AI 메시지(alignLeft == true)일 때만 마크다운 렌더링 적용
              child: alignLeft
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
                      h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                      h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                      h3: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, height: 1.4),
                      // 목록(-, 1.) 점/숫자 스타일
                      listBullet: TextStyle(
                        color: textColor,
                        fontSize: 15.5,
                      ),
                      listIndent: 16.0,
                      // 인용구(> ) 스타일
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade400, width: 3.0),
                        ),
                      ),
                      blockquotePadding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
                      // `인라인 코드` 스타일
                      code: const TextStyle(
                        backgroundColor: Color(0xFFE6E8EC),
                        color: Color(0xFFD6336C), // 포인트 컬러로 코드 강조
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
}