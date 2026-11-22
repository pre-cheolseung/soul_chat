import 'package:flutter/material.dart';

class PointNotification extends StatelessWidget {
  final int point;   // 포인트

  const PointNotification({
    super.key,

    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7.0,
        vertical: 2.0
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: const Color(0xFFD6CCFF),   // 은은한 라벤더 테두리
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 11.0,
            color: Color(0xFF7C5DFA),   // 메인 라벤더 포인트
          ),
          const SizedBox(width: 3.0),
          Text(
            ' +${point}P credited!',
            style: const TextStyle(
              color: Color(0xFF6A4CE6),
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}