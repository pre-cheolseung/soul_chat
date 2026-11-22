import 'package:flutter/material.dart';

class AppSnackBar {
  // 일반 안내용 스낵바 (완료, 안내 등)
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFFB5A4FA),   // 소프트 라벤더
      duration: const Duration(seconds: 3),
    );
  }

  // 성공 및 완료용 스낵바 (복사 성공, 파일 저장 완료 등)
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF8CE0A8),   // 다크 퍼플 배경 위에서 산뜻한 파스텔 민트
      duration: const Duration(seconds: 1),
    );
  }

  // 에러 알림용 스낵바 (네트워크 오류, 파일 열기 실패 등)
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFFF8A8A),   // 다크 퍼플 배경 위에서 부드러운 코랄 레드
      duration: const Duration(seconds: 5),
      showConfirmButton: true,   // 에러는 사용자가 직접 닫을 수 있게 Confirm 버튼 포함
    );
  }

  // 내부 공통 빌더 (웜 라벤더 다크 캡슐 디자인 통일)
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    required Duration duration,
    bool showConfirmButton = false,
  }) {
    if (!context.mounted) return;

    // 기존 스낵바가 떠 있다면 즉시 닫고 새 알림 표시
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D2254),   // 딥 퍼플 다크 배경
        elevation: 6.0,
        duration: duration,
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
            Icon(
              icon,
              color: iconColor,
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
        action: showConfirmButton
            ? SnackBarAction(
                label: 'Confirm',
                textColor: const Color(0xFFB5A4FA),   // 소프트 라벤더 버튼 텍스트
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }
}