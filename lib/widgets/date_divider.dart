import 'package:flutter/material.dart';

import 'package:soul_chat/utils/date_formatter.dart';

class DateDivider extends StatelessWidget {
  final DateTime date;

  const DateDivider({
    super.key,

    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 왼쪽 라벤더 구분선
        const Expanded(
          child: Divider(
            color: Color(0xFFE6E0FF),
            thickness: 1.0,
            indent: 16.0,
            endIndent: 12.0,
          ),
        ),
        // 중앙 날짜 알약 배지
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14.0,
            vertical: 5.0
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F5FA),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: const Color(0xFFE2D9FF),
              width: 1.0,
            ),
          ),
          child: Text(
            DateFormatter.formatDividerDate(date),
            style: const TextStyle(
              color: Color(0xFF6A5D94),
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        // 오른쪽 라벤더 구분선
        const Expanded(
          child: Divider(
            color: Color(0xFFE6E0FF),
            thickness: 1.0,
            indent: 12.0,
            endIndent: 16.0,
          ),
        ),
      ],
    );
  }
}