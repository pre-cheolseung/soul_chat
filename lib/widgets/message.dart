import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:soul_chat/utils/app_snack_bar.dart';
import 'package:soul_chat/utils/date_formatter.dart';
import 'package:soul_chat/widgets/markdown_message_text.dart';
import 'package:soul_chat/widgets/message_attachment.dart';
import 'package:soul_chat/widgets/point_notification.dart';

class Message extends StatefulWidget {
  final bool alignLeft;
  final String message;
  final int? point;
  final String? filePath;   // 첨부파일 경로
  final String? mimeType;   // 첨부파일 MIME 타입
  final DateTime date;   // 메시지 전송 시간


  const Message({
    super.key,

    this.alignLeft = true,
    required this.message,
    this.point,
    this.filePath,
    this.mimeType,
    required this.date,
  });

  @override
  // State<Message> createState() => _MessageState();
  State<Message> createState() {
    return _MessageState();
  }
}

class _MessageState extends State<Message> {
  bool _isCopied = false;   // 복사 완료 피드백 상태

  // 전체 메시지 복사
  Future<void> _copyAllText() async {
    await Clipboard.setData(ClipboardData(text: widget.message));
    if (!mounted) return;

    // 상태 변경 시 setState() 함수 실행
    // 값 변경 시 build() 함수 재실행
    // Clean -> setState() -> Dirty -> build() -> Clean
    setState(() => _isCopied = true);
    AppSnackBar.showSuccess(context, 'The entire message has been copied!');   // 복사 성공 안내

    // 1.5초 후 원래 복사 아이콘으로 복귀
    await Future.delayed(const Duration(milliseconds: 1500));
    // 상태 변경 시 setState() 함수 실행
    // 값 변경 시 build() 함수 재실행
    // Clean -> setState() -> Dirty -> build() -> Clean
    if (mounted) setState(() => _isCopied = false);
  }

  @override
  Widget build(BuildContext context) {
    final alignment = widget.alignLeft ? Alignment.centerLeft : Alignment.centerRight;   // alignLeft 기준으로 Alignment 프로퍼티 생성
    // 내 메시지(오른쪽 정렬)는 포인트 컬러
    final bgColor = widget.alignLeft ? const Color(0xFFF6F5FA) : const Color(0xFFF2EEFF);
    // final textColor = alignLeft ? const Color(0xFF1F1B2E) : const Color(0xFF2D2254);
    final textColor = widget.alignLeft ? const Color(0xFF3A3256) : const Color(0xFF2D2254);
    final borderColor = widget.alignLeft ? const Color(0xFFEBE8F5) : const Color(0xFFE2D9FF);
    final hasFile = widget.filePath != null && widget.filePath!.isNotEmpty;
    final hasText = widget.message.trim().isNotEmpty;

    return Align(
      alignment: alignment,
      // IntrinsicWidth로 감싸서 말풍선의 실제 가로 폭과 하단 아이콘 줄의 가로 폭을 일치시킴
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 말풍선 컨테이너
            Container(
              // 이미지가 너무 커져서 화면을 다 덮지 않도록 최대 가로 폭 제한
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              // 말풍선 꼬리 느낌을 주는 비대칭 모서리
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.alignLeft ? 4.0 : 20.0),
                  topRight: Radius.circular(widget.alignLeft ? 20.0 : 4.0),
                  bottomLeft: const Radius.circular(20.0),
                  bottomRight: const Radius.circular(20.0),
                ),
                border: Border.all(
                  color: borderColor,
                  width: 1.0,
                ),
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
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
                // AI 메시지(alignLeft == true)일 때만 마크다운 렌더링 적용
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 첨부파일이 있는 경우 상단에 먼저 렌더링
                    if (hasFile)
                      MessageAttachment(
                        filePath: widget.filePath!,
                        mimeType: widget.mimeType,
                        textColor: textColor,
                      ),

                    // 파일과 텍스트가 둘 다 있을 때만 중간 여백 추가
                    if (hasFile && hasText) const SizedBox(height: 8.0),

                    // 텍스트가 있는 경우 렌더링 (AI 마크다운 vs 사용자 일반 텍스트)
                    if (hasText)
                      widget.alignLeft
                        ? MarkdownMessageText(
                            message: widget.message,
                            textColor: textColor,
                          )
                        : SelectionArea(
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15.5,
                                height: 1.45,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                  ],
                )
              ),
            ),
            // 말풍선 바로 아래 원터치 전체 복사 버튼 + 포인트 알림 배치
            if (hasText || hasFile || widget.point != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 4.0,
                  left: 4.0,
                  right:4.0,
                ),
                child: Row(
                  // AI 답변은 좌측 끝(start), 내 메시지는 우측 끝(end)에 정렬
                  mainAxisAlignment: widget.alignLeft
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                  children: [
                    // 내 메시지일 때 우측 하단에 포인트, 시간 순서
                    if (!widget.alignLeft) ...[
                      if (widget.point != null) ...[
                        PointNotification(point: widget.point!),
                        const SizedBox(width: 6.0),
                      ],
                      // 말풍선 하단 시간 표시
                      Text(
                        DateFormatter.formatMessageTime(widget.date),
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Colors.black38,
                        ),
                      ),
                    ],

                    // AI 답변일 때 좌측 하단에 복사 버튼, 시간 순서
                    if (widget.alignLeft) ...[
                      if (hasText) ...[
                        InkWell(
                          onTap: _copyAllText,
                          borderRadius: BorderRadius.circular(12.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 2.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                                  size: 13.5,
                                  color: _isCopied ? const Color(0xFF7C5DFA) : Colors.black38,
                                ),
                                const SizedBox(width: 3.0),
                                Text(
                                  _isCopied ? 'Copied' : 'Copy',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: _isCopied ? const Color(0xFF7C5DFA) : Colors.black38,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                      ],
                      // 말풍선 하단 시간 표시
                      Text(
                        DateFormatter.formatMessageTime(widget.date),
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}