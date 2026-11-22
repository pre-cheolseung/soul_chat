import 'package:flutter/material.dart';

class AppSnackBar {
  // 에러 알림용 스낵바
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    // 기존 스낵바가 떠 있다면 즉시 닫고 새 알림 표시
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D2254),   // 딥 퍼플 다크 배경
        elevation: 6.0,
        margin: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(
            color: Color(0xFF7C5DFA),   // 웜 라벤더 포인트 테두리
            width: 1.0,
          ),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF8A8A),   // 어두운 배경 위에서 부드럽게 강조되는 코랄 레드
              size: 20.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Confirm',
          textColor: const Color(0xFFB5A4FA),   // 소프트 라벤더 버튼 텍스트
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}