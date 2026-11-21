import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:soul_chat/components/point_notification.dart';
import 'package:soul_chat/widget/full_screen_image_viewer.dart';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';   // 마크다운 패키지
import 'package:markdown/markdown.dart' as md;
import 'package:open_filex/open_filex.dart';   // 기본 뷰어 앱 연결 패키지

class Message extends StatefulWidget {
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

  @override
  // State<Message> createState() => _MessageState();
  State<Message> createState() {
    return _MessageState();
  }
}

class _MessageState extends State<Message> {
  bool _isCopied = false;   // 복사 완료 피드백 상태

  // 파일 확장자가 이미지인지 판별
  bool _isImage() {
    if (widget.mimeType != null && widget.mimeType!.startsWith('image/')) {
      return true;
    }
    if (widget.filePath != null) {
      final lower = widget.filePath!.toLowerCase();

      return lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp');
    }

    return false;
  }

  // 전체 메시지 복사
  Future<void> _copyAllText() async {
    await Clipboard.setData(ClipboardData(text: widget.message));
    if (!mounted) return;

    setState(() => _isCopied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The entire message has been copied!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 1.5초 후 원래 복사 아이콘으로 복귀
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isCopied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alignment = widget.alignLeft ? Alignment.centerLeft : Alignment.centerRight;   // alignLeft 기준으로 Alignment 프로퍼티 생성
    // 내 메시지(왼쪽 정렬)는 포인트 컬러
    final bgColor = widget.alignLeft ? const Color(0xFFF6F5FA) : const Color(0xFFF2EEFF);
    // final textColor = alignLeft ? const Color(0xFF1F1B2E) : const Color(0xFF2D2254);
    final textColor = widget.alignLeft ? const Color(0xFF3A3256) : const Color(0xFF2D2254);
    final borderColor = widget.alignLeft ? const Color(0xFFEBE8F5) : const Color(0xFFE2D9FF);
    final hasFile = widget.filePath != null && widget.filePath!.isNotEmpty;
    final hasText = widget.message.trim().isNotEmpty;

    // 마크다운 보정
    // String _fixKoreanMarkdown(String text) {
    //   // **텍스트(괄호)** 뒤에 한글이 바로 붙는 경우 -> 괄호를 ** 바깥으로 이동
    //   var fixed = text.replaceAllMapped(
    //     RegExp(r'\*\*([^*]+?)(\([^)]+\))\*\*'),
    //     (match) => '**${match.group(1)}**${match.group(2)}',
    //   );

    //   // 그 외 문장부호 뒤에 **가 오고 바로 글자가 붙는 경우 -> ** 뒤에 한 칸 띄어쓰기 추가
    //   fixed = fixed.replaceAllMapped(
    //     RegExp(r'\*\*([^*]+?[\)\]\}"' "'" r'!\?])\*\*([^\s])'),
    //     (match) => '**${match.group(1)}** ${match.group(2)}',
    //   );

    //   return fixed;
    // }

    return Column(
      children: [
        Align(
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
                      vertical: 12.0,
                      horizontal: 14.0,
                    ),
                    // AI 메시지(alignLeft == true)일 때만 마크다운 렌더링 적용
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 첨부파일이 있는 경우 상단에 먼저 렌더링
                        if (hasFile) _buildAttachment(context, widget.filePath!, textColor),

                        // 파일과 텍스트가 둘 다 있을 때만 중간 여백 추가
                        if (hasFile && hasText) const SizedBox(height: 8.0),

                        // 텍스트가 있는 경우 렌더링
                        if (hasText)
                        // 부분 드래그 선택이 가능한 텍스트 영역 (SelectionArea)
                        SelectionArea(
                          // OS 기본 툴바 대신 높이와 정렬이 완벽히 맞는 커스텀 툴바 사용
                          contextMenuBuilder: (context, selectableRegionState) {
                            final anchors = selectableRegionState.contextMenuAnchors;
                            final buttonItems = selectableRegionState.contextMenuButtonItems;

                            return AdaptiveTextSelectionToolbar(
                              anchors: anchors,
                              children: buttonItems.map((item) {
                                final label = switch (item.type) {
                                  ContextMenuButtonType.copy => '복사',
                                  ContextMenuButtonType.selectAll => '모두 선택',
                                  ContextMenuButtonType.share => '공유',
                                  _ => item.label ?? '',
                                };

                                return TextSelectionToolbarTextButton(
                                  padding: TextSelectionToolbarTextButton.getPadding(
                                    buttonItems.indexOf(item),
                                    buttonItems.length,
                                  ),
                                  onPressed: item.onPressed,
                                  child: Text(
                                    label,
                                    // 글자 위아래 높이만 강제 통일해 '모두 선택'이 들뜨는 현상 방지
                                    strutStyle: const StrutStyle(
                                      fontSize: 14.0,
                                      height: 1.0,
                                      forceStrutHeight: true,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      height: 1.0,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          child: widget.alignLeft
                            ? MarkdownBody(
                                // data: _fixKoreanMarkdown(widget.message),
                                data: widget.message,
                                fitContent: true,   // 짧은 문장일 때 말풍선이 불필요하게 넓어지지 않게 설정
                                inlineSyntaxes: [_FlexibleEmphasisSyntax()],   // 괄호까지 포함해 렌더링
                                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
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
                                    color: Color(0xFF140E29),
                                  ),
                                  // *기울임* 스타일
                                  em: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF4C436E),
                                  ),
                                  // 제목(#, ##, ###) 스타일
                                  h1: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF140E29),
                                    height: 1.4,
                                  ),
                                  h2: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF140E29),
                                    height: 1.4,
                                  ),
                                  h3: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF140E29),
                                    height: 1.4,
                                  ),
                                  // 하이퍼링크([텍스트](URL)) 스타일
                                  a: const TextStyle(
                                    color: Color(0xFF6A4CE6),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF6A4CE6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // 가로 구분선(---) 스타일
                                  horizontalRuleDecoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Color(0xFFE2D9FF),
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                  // 표(Table) 스타일
                                  tableHead: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D2254),
                                    fontSize: 14.5,
                                  ),
                                  tableBody: TextStyle(
                                    color: textColor,
                                    fontSize: 14.5,
                                  ),
                                  tableBorder: TableBorder.all(
                                    color: const Color(0xFFDCD3FF),
                                    width: 1.0,
                                  ),
                                  tableHeadAlign: TextAlign.left,
                                  tableCellsPadding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 8.0,
                                  ),
                                  // 목록(-, 1.) 점/숫자 스타일
                                  listBullet: TextStyle(
                                    color: Color(0xFF7C5DFA),
                                    fontSize: 15.5,
                                  ),
                                  listIndent: 16.0,
                                  // 인용구(> ) 스타일
                                  blockquoteDecoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Color(0xFFB5A4FA),
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                  blockquotePadding: const EdgeInsets.only(
                                    left: 12.0,
                                    top: 4.0,
                                    bottom: 4.0,
                                  ),
                                  // `인라인 코드` 스타일
                                  code: const TextStyle(
                                    backgroundColor: Color(0xFFECE6FF),
                                    color: Color(0xFF5A3EE8),   // 포인트 컬러로 코드 강조
                                    fontFamily: 'monospace',
                                    fontSize: 13.5,
                                  ),
                                  // ```코드 블록``` 스타일
                                  codeblockDecoration: BoxDecoration(
                                    color: const Color(0xFFECE8F8),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: const Color(0xFFDCD3FF),
                                      width: 1.0,
                                    ),
                                  ),
                                  codeblockPadding: const EdgeInsets.all(14.0),
                                ),
                              )
                          : Text(
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
                if (hasText || widget.point != null)
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
                        // 내 메시지일 때 포인트만 우측 표시
                        if (!widget.alignLeft && widget.point != null)
                          PointNotification(point: widget.point!),

                        // AI 답변일 때만 하단 좌측에 복사 버튼 표시
                        if (hasText && widget.alignLeft)
                          InkWell(
                            onTap: _copyAllText,
                            borderRadius: BorderRadius.circular(12.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                                    size: 14.0,
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
                      ],
                    ),
                  ),
              ],
            ),
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
                heroTag: path,   // 파일 경로를 고유 태그로 사용
              ),
            ),
          );
        },
        child: Hero(
          tag: path,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: ConstrainedBox(
              // 이미지가 너무 길어서 스크롤 계산을 망가뜨리지 않도록 최대 높이 제한
              constraints: const BoxConstraints(
                maxWidth: 220.0,
                maxHeight: 260.0,
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
    final fileName = path.split('/').last;
    return GestureDetector(
      onTap: () async {
        final result = await OpenFilex.open(path);
        // 기기에 해당 파일을 열 수 있는 앱이 없는 경우 안내 스낵바 표시
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,   // 화면 위에 떠 있는 스타일
              content: Text(
                'Cannot open file : ${result.message}',
              ),
              // 확인 버튼
              action: SnackBarAction(
                label: 'Confirm',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
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

// CommonMark의 괄호/조사 제약 없이 텍스트(괄호 포함)를 굵게 처리하는 커스텀 문법
// ***, **, * 강조 문법을 우선순위대로 한 번에 처리하는 통합 문법
class _FlexibleEmphasisSyntax extends md.InlineSyntax {
  _FlexibleEmphasisSyntax()
      : super(r'(\*\*\*(.+?)\*\*\*|\*\*(.+?)\*\*|\*(.+?)\*)', startCharacter: 0x2A);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    if (match.group(2) != null) {
      // 1. ***굵은 기울임***
      final children = parser.document.parseInline(match.group(2)!);
      parser.addNode(md.Element('strong', [md.Element('em', children)]));
    } else if (match.group(3) != null) {
      // 2. **굵은 글씨**
      final children = parser.document.parseInline(match.group(3)!);
      parser.addNode(md.Element('strong', children));
    } else if (match.group(4) != null) {
      // 3. *기울임꼴*
      final children = parser.document.parseInline(match.group(4)!);
      parser.addNode(md.Element('em', children));
    }
    return true;
  }
}