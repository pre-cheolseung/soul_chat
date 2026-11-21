import 'package:flutter/material.dart';

import 'package:soul_chat/components/date_divider.dart';
import 'package:soul_chat/components/logo.dart';
import 'package:soul_chat/components/message.dart';
import 'package:soul_chat/model/message_model.dart';

import 'package:intl/intl.dart';   // DateFormat 사용

// DateTime now = DateTime.now();
// final monthLong = DateFormat('MMMM', 'en_US').format(now);   // 월을 영어 전체 이름으로 표시 (예: November)
// String monthShort = DateFormat('MMM', 'en_US').format(now);   // 월을 영어 약자로 표시 (예: Nov)
// String monthLong = DateFormat('MMMM', 'en_US').format(now);   // 월을 영어 전체 이름으로 표시 (예: November)
// String fullDate = DateFormat.yMMMd('en_US').format(now);   // 연, 월, 일을 영어 형식으로 표시 (예: Nov 17, 2026)

class MessageListView extends StatelessWidget {
  final ScrollController scrollController;
  final List<MessageModel> messages;

  const MessageListView({
    super.key,
    required this.scrollController,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final reversedMessages = messages.reversed.toList();   // 최신 메시지가 0번(맨 아래)에 오도록 역순 변환

    return ListView.separated(
      controller: scrollController,   // 선언한 컨트롤러를 ListView에 입력
      reverse: true,   // 최하단(0.0)을 기준점으로 고정
      itemBuilder: (context, index) {
        // 가장 마지막 인덱스(화면 맨 위)에 로고 배치
        if (index == reversedMessages.length) {
          return _buildLogo();
        }

        // 시간순 직전 메시지는 역순 리스트에서 'index + 1' 위치
        final currentMessage = reversedMessages[index];
        final prevMessage = (index + 1 < reversedMessages.length)
            ? reversedMessages[index + 1]
            : null;
        final originalIndex = reversedMessages.length - 1 - index;

        return _buildMessageItem(
          message: currentMessage,
          prevMessage: prevMessage,
          index: originalIndex,
        );
      },
      itemCount: messages.length + 1,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,   // 스크롤 시 키보드 숨김
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
    );
  }

  // 로고를 보여줄 위젯
  Widget _buildLogo() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 60.0,
      ),
      child: Logo(),
    );
  }

  // 메시지를 화면에 그리는 함수
  Widget _buildMessageItem({
    MessageModel? prevMessage,
    required MessageModel message,
    required int index,
  }) {
    final isMine = message.isMine;
    // DateDivider 위젯을 그려야 하는지 판단
    final shouldDrawDateDivider = prevMessage == null || _shouldDrawDate(prevMessage.date, message.date);

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
            filePath: message.filePath,
            mimeType: message.mimeType,
          ),
        ),
      ],
    );
  }

  // String으로 반환된 날짜가 다를 경우 true 반환
  bool _shouldDrawDate(DateTime date1, DateTime date2) {
    return _getStringDate(date1) != _getStringDate(date2);
  }

  String _getStringDate(DateTime date) {
    // return '${date.year}년 ${date.month}월 ${date.day}일';   // DateTime을 '2026년 11월 17일' 형태로 반환
    // return '$monthLong ${now.day}, ${now.year}';   // DateTime을 'November 17, 2026' 형태로 반환
    return DateFormat('MMMM d, y', 'en_US').format(date);   // DateTime을 'November 17, 2026' 형태로 반환
  }
}