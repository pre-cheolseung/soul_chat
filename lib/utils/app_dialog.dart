import 'package:flutter/material.dart';

class AppDialog {
  // 단순 안내 및 알림용 (안내, 버전 정보 등 : 버튼 1개만 표시)
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'Got it',
    IconData icon = Icons.auto_awesome_rounded,
  }) async {
    await _show(
      context,
      title: title,
      content: content,
      icon: icon,
      iconColor: const Color(0xFF7C5DFA),
      iconBgColor: const Color(0xFFF2EEFF),
      iconBorderColor: const Color(0xFFE2D9FF),
      confirmButtonColor: const Color(0xFF7C5DFA),
      confirmText: buttonText,
      isSingleButton: true,
    );
  }

  // 일반 확인 및 선택용 (변경, 기능 확인 등 : 메인 웜 라벤더 버튼)
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    IconData icon = Icons.help_outline_rounded,
  }) async {
    return _show(
      context,
      title: title,
      content: content,
      icon: icon,
      iconColor: const Color(0xFF7C5DFA),
      iconBgColor: const Color(0xFFF2EEFF),
      iconBorderColor: const Color(0xFFE2D9FF),
      confirmButtonColor: const Color(0xFF7C5DFA),
      cancelText: cancelText,
      confirmText: confirmText,
    );
  }

  // 위험 및 삭제 확인용 (삭제, 계정 탈퇴 등 : 코랄 레드 버튼)
  static Future<bool> showDanger(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'Delete',
    IconData icon = Icons.delete_outline_rounded,
  }) async {
    return _show(
      context,
      title: title,
      content: content,
      icon: icon,
      iconColor: const Color(0xFFFF5A6E),
      iconBgColor: const Color(0xFFFFF0F2),
      iconBorderColor: const Color(0xFFFFD6DC),
      confirmButtonColor: const Color(0xFFFF5A6E),
      cancelText: cancelText,
      confirmText: confirmText,
    );
  }

  // 내부 공통 빌더
  static Future<bool> _show(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color iconBorderColor,
    required Color confirmButtonColor,
    String cancelText = 'Cancel',
    required String confirmText,
    bool isSingleButton = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconBorderColor,
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 26.0,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF140E29),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14.0,
            height: 1.5,
            color: Color(0xFF4C436E),
          ),
        ),
        actions: [
          Row(
            children: [
              // 2버튼 일 때만 왼쪽 Cancel 버튼 표시
              if (!isSingleButton) ...[
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
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
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
              ],
              // 오른쪽 확인 및 삭제 버튼
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: TextButton.styleFrom(
                    backgroundColor: confirmButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return result ?? false;
  }
}