import 'package:flutter/material.dart';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';   // 마크다운 패키지
import 'package:markdown/markdown.dart' as md;   // 마크다운 패키지

class MarkdownMessageText extends StatelessWidget {
  final String message;
  final Color textColor;

  const MarkdownMessageText({
    super.key,

    required this.message,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // 부분 드래그 선택이 가능한 텍스트 영역 (SelectionArea)
    return SelectionArea(
      // OS 기본 툴바 대신 높이와 정렬이 완벽히 맞는 커스텀 툴바 사용
      contextMenuBuilder: (context, selectableRegionState) {
        final buttonItems = selectableRegionState.contextMenuButtonItems;
        final anchors = selectableRegionState.contextMenuAnchors;

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
      child: MarkdownBody(
        data: message,
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
      // ***굵은 기울임***
      final children = parser.document.parseInline(match.group(2)!);
      parser.addNode(md.Element('strong', [md.Element('em', children)]));
    } else if (match.group(3) != null) {
      // **굵은 글씨**
      final children = parser.document.parseInline(match.group(3)!);
      parser.addNode(md.Element('strong', children));
    } else if (match.group(4) != null) {
      // *기울임꼴*
      final children = parser.document.parseInline(match.group(4)!);
      parser.addNode(md.Element('em', children));
    }
    return true;
  }
}
