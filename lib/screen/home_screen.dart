import 'package:flutter/material.dart';

import 'package:soul_chat/components/date_divider.dart';
import 'package:soul_chat/components/logo.dart';
import 'package:soul_chat/components/message.dart';
import 'package:soul_chat/model/message_model.dart';

import 'package:intl/intl.dart';

DateTime now = DateTime.now();
// String monthShort = DateFormat('MMM', 'en_US').format(now);   // 월을 영어 약자로 표시 (예: Nov)
String monthLong = DateFormat('MMMM', 'en_US').format(now);   // 월을 영어 전체 이름으로 표시 (예: November)
// String fullDate = DateFormat.yMMMd('en_US').format(now);   // 연, 월, 일을 영어 형식으로 표시 (예: Nov 17, 2026)

final sampleData = [
  MessageModel(
    date: DateTime(2026, 11, 17),
    id: 1,
    isMine: true,
    message: '오늘 저녁으로 먹을 만한 메뉴 추천해줘!',
    point: 1,
  ),
  MessageModel(
    date: DateTime(2026, 11, 17),
    id: 2,
    isMine: false,
    message: '칼칼한 김치찜은 어때요?!',
    point: null,
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);   // const 생성자 : 최초 선언 후 변경 불가능한 빌드 타임 함수

  @override
  // State<HomeScreen> createState() => _HomeScreenState();
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildMessageList(),
    );
  }

  Widget buildMessageList() {
    return ListView.separated(
      itemBuilder: (context, index) => index == 0
        ? buildLogo()
        : buildMessageItem(
            message: sampleData[index - 1],
            prevMessage: index > 1 ? sampleData[index - 2] : null,
            index: index - 1,
          ),
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
      itemCount: sampleData.length + 1,
    );
  }

  Widget buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Padding(
        padding: EdgeInsets.only(bottom: 60.0),
        child: Logo(),
      ),
    );
  }

  Widget buildMessageItem({
    MessageModel? prevMessage,
    required MessageModel message,
    required int index,
  }) {
    final isMine = message.isMine;
    // DateDivider 위젯을 그려야 하는지 판단
    final shouldDrawDateDivider = prevMessage == null || shouldDrawDate(prevMessage.date, message.date);

    return Column(
      children: [
        // DateDivider 위젯을 그려야 하는지 판단
        if (shouldDrawDateDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: DateDivider(date: message.date),
          ),
        // 정렬 위치에 따라 패딩 다르게 제공
        Padding(
          padding: EdgeInsets.only(
            left: isMine ? 64.0 : 16.0,
            right: isMine ? 16.0 : 64.0,
          ),
          child: Message(
            alignLeft: !isMine,
            message: message.message.trim(),
            point: message.point,
          ),
        ),
      ],
    );
  }

  // String으로 반환된 날짜라 다를 경우 true 반환
  bool shouldDrawDate(DateTime date1, DateTime date2) {
    return getStringDate(date1) != getStringDate(date2);
  }

  // DateTime을 '2026년 11월 17일' 형태로 반환
  // DateTime을 'November 17, 2026' 형태로 반환
  String getStringDate(DateTime date) {
    // return '${date.year}년 ${date.month}월 ${date.day}일';
    return '$monthLong ${date.day}, ${date.year}';
  }
}