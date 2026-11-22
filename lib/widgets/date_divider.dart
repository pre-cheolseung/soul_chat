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
    return Text(
      DateFormatter.formatDividerDate(date),
      style: TextStyle(
        color: Colors.black54,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}