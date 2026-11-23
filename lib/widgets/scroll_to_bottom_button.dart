import 'package:flutter/material.dart';

// 다크 및 포인트 컬러 알약형 버튼 (텍스트 + 아이콘)
class ScrollToBottomButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onTap;

  const ScrollToBottomButton({
    super.key,
    required this.isVisible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 16.0,
      // 숨겨진 상태(isVisible == false)일 때 투명한 버튼이 잘못 눌리지 않도록 터치 차단
      child: IgnorePointer(
        ignoring: !isVisible,
        // isVisible 값에 따라 0.25초 동안 부드럽게 투명도 조절
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Center(
            child: Material(
              color: const Color(0xFF4A3B8C),   // 버튼 배경색
              elevation: 4.0,   // 그림자 깊이 (0으로 하면 그림자 제거)
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20.0),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18.0,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        'To the latest conversation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}