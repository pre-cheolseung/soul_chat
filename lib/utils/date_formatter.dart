import 'package:intl/intl.dart';   // DateFormat 사용

// DateTime now = DateTime.now();
// final monthLong = DateFormat('MMMM', 'en_US').format(now);   // 월을 영어 전체 이름으로 표시 (예: November)
// String monthShort = DateFormat('MMM', 'en_US').format(now);   // 월을 영어 약자로 표시 (예: Nov)
// String monthLong = DateFormat('MMMM', 'en_US').format(now);   // 월을 영어 전체 이름으로 표시 (예: November)
// String fullDate = DateFormat.yMMMd('en_US').format(now);   // 연, 월, 일을 영어 형식으로 표시 (예: Nov 17, 2026)

class DateFormatter {
  // 날짜 구분선용 (November 22, 2026)
  static String formatDividerDate(DateTime date) {
    // return '${now.year}년 ${now.month}월 ${now.day}일';   // DateTime을 '2026년 11월 17일' 형태로 반환
    // return '$monthLong ${now.day}, ${now.year}';   // DateTime을 'November 17, 2026' 형태로 반환
    return DateFormat('MMMM d, y', 'en_US').format(date);   // DateTime을 'November 17, 2026' 형태로 반환
  }

  // 두 날짜가 서로 다른 날인지 판별 (날짜 구분선 표시 여부 판단용)
  // String으로 반환된 날짜가 다를 경우 true 반환
  static bool isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year || date1.month != date2.month || date1.day != date2.day;
  }

  // 말풍선 하단 전송 시간용
  static String formatMessageTime(DateTime date) {
    // return DateFormat('a h:mm', 'ko_KR').format(date);   // 오전 12:25, 오후 3:40
    return DateFormat('h:mm a', 'en_US').format(date);   // 12:25 AM, 3:40 PM
  }
}