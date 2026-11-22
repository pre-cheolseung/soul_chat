import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  // State<TypingIndicator> createState() => _TypingIndicatorState();
  State<TypingIndicator> createState() {
    return _TypingIndicatorState();
  }
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F5FA),   // AI 말풍선과 동일한 배경색
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(20.0),
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          border: Border.all(color: const Color(0xFFEBE8F5), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // 점 3개가 0.2초 간격으로 순차적으로 위아래로 움직이는 애니메이션
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.2;
                final value = (_controller.value - delay) % 1.0;
                // 0.0 ~ 0.5 구간에서만 위로 통통 튀도록 계산
                final offset = value < 0.5
                  ? -4.0 * (1 - (2 * value - 1) * (2 * value - 1))
                  : 0.0;

                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 5.0 : 0),
                    width: 7.0,
                    height: 7.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C5DFA).withValues(
                        alpha: value < 0.5 ? 0.9 : 0.35,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}