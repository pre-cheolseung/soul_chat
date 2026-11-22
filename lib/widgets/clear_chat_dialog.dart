import 'package:flutter/material.dart';

class ClearChatDialog extends StatelessWidget {
  const ClearChatDialog({super.key});

  // 외부에서 한 줄로 편하게 호출할 수 있는 정적 메서드
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const ClearChatDialog(),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(
          color: Color(0xFFE2D9FF),   // 웜 라벤더 테두리
          width: 1.2,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 10.0),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
      actionsPadding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      title: Column(
        children: [
          // 상단 휴지통 아이콘 포인트 배지
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EEFF),   // 소프트 웜 라벤더 배경
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2D9FF),
                width: 1.0,
              ),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF7C5DFA),   // 메인 웜 라벤더 아이콘
              size: 26.0,
            ),
          ),
          const SizedBox(height: 14.0),
          const Text(
            'Clear Chat History',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF140E29),   // 딥 퍼플 블랙
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      content: const Text(
        'All conversation history will be deleted and cannot be recovered.\n'
        'Are you sure you want to delete it?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.0,
          height: 1.5,
          color: Color(0xFF4C436E),   // 차분한 딥 라벤더 그레이
        ),
      ),
      actions: [
        Row(
          children: [
            // 취소 버튼 (소프트 라벤더 캡슐)
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF6F5FA),
                  foregroundColor: const Color(0xFF4C436E),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    side: const BorderSide(
                      color: Color(0xFFEBE8F5),
                      width: 1.0,
                    ),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            // 삭제 확정 버튼 (코랄 레드 캡슐)
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5A6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}