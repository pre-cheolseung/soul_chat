import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

DateTime now = DateTime.now();
// String monthShort = DateFormat('MMM', 'en_US').format(now);   // 월을 영어 약자로 표시 (예: Nov)
String monthLong = DateFormat('MMMM', 'en_US').format(now);   // 월을 영어 전체 이름으로 표시 (예: November)
// String fullDate = DateFormat.yMMMd('en_US').format(now);   // 연, 월, 일을 영어 형식으로 표시 (예: Nov 17, 2026)

class DateDivider extends StatelessWidget {
  final DateTime date;

  const DateDivider({
    super.key,

    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      // '${date.year}년 ${date.month}월 ${date.day}일',
      '$monthLong ${date.day}, ${date.year}',
      style: TextStyle(
        color: Colors.black54,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}