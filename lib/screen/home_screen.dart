import 'package:flutter/material.dart';

import 'package:soul_chat/components/chat_text_field.dart';
import 'package:soul_chat/components/date_divider.dart';
import 'package:soul_chat/components/logo.dart';
import 'package:soul_chat/components/message.dart';
import 'package:soul_chat/model/message_model.dart';

import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

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
  final TextEditingController controller = TextEditingController();
  bool isRunning = false;   // 로딩 여부를 확인하는 변수
  String? error;   // 에러 메시지 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ListView와 TextField를 세로로 정렬
      body: SafeArea(
        child: Column(
          children: [
            // ListView가 화면을 최대한으로 차지하도록 설정
            Expanded(
              child: buildMessageList(),
            ),
            ChatTextField(
              controller: controller,
              onSend: handleSendMessage,
              error: error,
              loading: isRunning,
            ),
          ],
        ),
      ),
    );
  }

  handleSendMessage() async {
    // TextField에 입력된 메시지가 없으면 에러 출력
    if(controller.text.isEmpty) {
      // 상태 변경 시 setState() 함수 실행
      // 값 변경 시 build() 함수 재실행
      // Clean -> setState() -> Dirty -> build() -> Clean
      setState(() => error = 'Please enter a message!');

      return;
    }

    int? currentModelMessageId;   // 현재 응답받고 있는 메시지 ID (스트림으로 지속적 업데이트)
    int? currentUserMessageId;   // 내가 보낸 메시지에 배정된 ID (에러가 발생하면 삭제)
    final isar = GetIt.I<Isar>();   // Isar 인스턴스 변수
    final currentPrompt = controller.text;   // TextField에 입력된 값을 저장하는 변수

    try {
      // 로딩 중으로 상태 변경
      // 상태 변경 시 setState() 함수 실행
      // 값 변경 시 build() 함수 재실행
      // Clean -> setState() -> Dirty -> build() -> Clean
      setState(() {
        isRunning = true;
      });

      controller.clear();   // TextField에 입력된 값 모두 삭제

      // 현재 데이터베이스에 저장되어 있는 내가 보낸 메시지 수 (포인트용)
      final myMessageCount = await isar.messageModels.filter().isMineEqualTo(true).count();

      // 내가 보낸 메시지 Isar에 저장
      currentUserMessageId = await isar.writeTxn(() async {
        return await isar.messageModels.put(
          MessageModel(
            date: DateTime.now(),
            isMine: true,
            message: currentPrompt,
            point: myMessageCount + 1,
          ),
        );
      });
    } catch (e) {
      // 에러가 있을 경우 SnackBar로 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,   // 화면 위에 떠 있는 스타일
          // 확인 버튼
          action: SnackBarAction(
            label: 'Confirm',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
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