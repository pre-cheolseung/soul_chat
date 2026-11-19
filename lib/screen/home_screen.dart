import 'package:flutter/material.dart';

import 'package:soul_chat/components/chat_text_field.dart';
import 'package:soul_chat/components/date_divider.dart';
import 'package:soul_chat/components/logo.dart';
import 'package:soul_chat/components/message.dart';
import 'package:soul_chat/model/message_model.dart';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

DateTime now = DateTime.now();
// String monthShort = DateFormat('MMM', 'en_US').format(now);   // 월을 영어 약자로 표시 (예: Nov)
String monthLong = DateFormat('MMMM', 'en_US').format(now);   // 월을 영어 전체 이름으로 표시 (예: November)
// String fullDate = DateFormat.yMMMd('en_US').format(now);   // 연, 월, 일을 영어 형식으로 표시 (예: Nov 17, 2026)

// 샘플 데이터
// final sampleData = [
//   MessageModel(
//     date: DateTime(2026, 11, 17),
//     id: 1,
//     isMine: true,
//     message: '오늘 저녁으로 먹을 만한 메뉴 추천해줘!',
//     point: 1,
//   ),
//   MessageModel(
//     date: DateTime(2026, 11, 17),
//     id: 2,
//     isMine: false,
//     message: '칼칼한 김치찜은 어때요?!',
//     point: null,
//   ),
// ];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);   // const 생성자 : 최초 선언 후 변경 불가능한 빌드 타임 함수

  @override
  // State<HomeScreen> createState() => _HomeScreenState();
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // Stream을 저장할 변수 선언과 동시에 초기화
  // 화면이 열릴 때 딱 한 번만 Stream 생성 (날짜순 정렬 포함)
  final Stream<List<MessageModel>> _messageStream = 
    GetIt.I<Isar>().messageModels.where().sortByDate().watch(fireImmediately: true);

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isRunning = false;   // 로딩 여부를 확인하는 변수
  String? error;   // 에러 메시지 변수

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;   // 키보드가 올라와 있는지 확인

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),   // 채팅 빈 화면을 터치하면 키보드 내리기
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true, //   명시적으로 활성화 (기본값)
        // ListView와 TextField를 세로로 정렬
        body: SafeArea(
          child: Column(
            children: [
              // ListView가 화면을 최대한으로 차지하도록 설정
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: _messageStream,   // 매번 새로 생성하지 않고 미리 만들어둔 변수 연결
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? [];
                    WidgetsBinding.instance.addPostFrameCallback((_) async => scrollToBottom());   // ListView의 가장 아래로 이동하는 함수
                    return buildMessageList(messages);   // 화면에 로고와 메시지들을 보여주는 ListView 함수
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                  bottom: isKeyboardOpen ? 8.0 : 24.0,   // 키보드가 열렸을 때는 여백을 좁히고, 닫혔을 때만 여유 있게 설정
                ),
                child: ChatTextField(
                  controller: controller,
                  onSend: handleSendMessage,   // 채팅 입력 TextField 함수
                  error: error,
                  loading: isRunning,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ListView 의 가장 아래로 이동하는 함수
  void scrollToBottom() {
    // 현재 위치가 최대 스크롤 가능 위치가 아닐 때만 실행
    if (scrollController.position.pixels != scrollController.position.maxScrollExtent) {
      // 원하는 위치까지 스크롤을 가능하도록 하는 함수
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,   // 최대 스크롤 가능한 위치를 pixel로 제공
        duration: const Duration(milliseconds: 300),   // 약 300ms에 걸쳐서 스크롤 애니메이션을 실행
        curve: Curves.easeOut,   // 애니메이션이 끝날수록 느려지는 유형으로 실행
      );
    }
  }

  // 채팅 입력 TextField 함수
  void handleSendMessage() async {
    if (isRunning) return;   // 이미 응답을 받는 중이면 중복 실행 방지

    final currentPrompt = controller.text;   // TextField에 입력된 값을 저장하는 변수

    // TextField에서 앞뒤 공백을 제거했을 때 입력된 메시지가 없으면 에러 출력 후 종료
    if (currentPrompt.trim().isEmpty) {
      // 상태 변경 시 setState() 함수 실행
      // 값 변경 시 build() 함수 재실행
      // Clean -> setState() -> Dirty -> build() -> Clean
      setState(() => error = 'Please enter a message!');

      return;
    }

    int? currentModelMessageId;   // 현재 응답받고 있는 메시지 ID (스트림으로 지속적 업데이트)
    int? currentUserMessageId;   // 내가 보낸 메시지에 배정된 ID (에러가 발생하면 삭제)
    final isar = GetIt.I<Isar>();   // Isar 인스턴스 변수

    try {
      // 로딩 중으로 상태 변경 및 기존 에러 메시지 초기화
      // 상태 변경 시 setState() 함수 실행
      // 값 변경 시 build() 함수 재실행
      // Clean -> setState() -> Dirty -> build() -> Clean
      setState(() {
        isRunning = true;
        error = null;
      });

      controller.clear();   // TextField에 입력된 값 모두 삭제

      // 현재 데이터베이스에 저장되어 있는 내가 보낸 메시지 수 (포인트용)
      final myMessagesCount = await isar.messageModels.filter().isMineEqualTo(true).count();

      // 내가 보낸 메시지를 Isar에 저장
      currentUserMessageId = await isar.writeTxn(() async {
        return await isar.messageModels.put(
          MessageModel(
            date: DateTime.now(),
            isMine: true,
            message: currentPrompt,
            point: myMessagesCount + 1,
          ),
        );
      });

      // 최근 5개의 메시지만 저장하는 변수 (방금 저장한 currentPrompt 포함)
      // 제미나이에게 현재까지 대화한 문맥을 제공
      // 최근 어느 정도 대화 히스토리를 함께 제공하는 것이 정확한 대답을 이끌어내기에 유용
      // 많은 대화 히스토리를 제공할 수록 비용 증가
      // 날짜 내림차순으로 내용이 비어있는 잘못된 메시지를 제외한 가장 최근 5개 메시지 변수에 저장 (최신순: 5 -> 4 -> 3 -> 2 -> 1)
      // final contextMessages = await isar.messageModels.where().limit(5).findAll();
      final contextMessages = await isar.messageModels.filter().messageIsNotEmpty().sortByDateDesc().limit(5).findAll();
      // 제미나이가 대화 흐름을 이해할 수 있도록 시간순으로 뒤집어서 변환 (과거 -> 최신)
      final List<Content> promptContext = contextMessages.reversed.map(
        (e) => Content(
          e.isMine ? 'user' : 'model',
          [
            TextPart(e.message),
          ],
        ),
      ).toList();
      // 사용할 제미나이 모델 인스턴스 초기화 (Gemini Developer API 기준)
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3.5-flash-lite',
        generationConfig: GenerationConfig(
          // 내부 추론(thinkingLevel)을 최소화로 설정하여 빠른 답변 시작
          thinkingConfig: ThinkingConfig.withThinkingLevel(ThinkingLevel.minimal),
          // maxOutputTokens: 500,   // 답변 길이를 적당히 제한하여 생성 시간 단축
          temperature: 0.8,   // 0.7~0.9 사이로 높이면 말투가 더 다채롭고 자연스러워짐
        ),
        systemInstruction: Content.system(
          '당신은 착하고 친절한 단짝 친구입니다. '
          '항상 따뜻하고 긍정적인 말투로 공감해 주고, '
          '단답형 대신 2~3문장 정도로 다정하게 대답하며 대화가 이어질 수 있도록 가벼운 질문도 함께 건네주세요.'
        ),
      );

      String message = '';   // Stream으로 받아지는 메시지를 지속적으로 추가할 문자열
      String lastSavedMessage = '';   // 마지막으로 Isar에 저장된 텍스트 추적용
      final responseDate = DateTime.now();    // 응답 시작 시간을 루프 밖에서 고정
      DateTime lastDbUpdate = DateTime.fromMillisecondsSinceEpoch(0);   // 마지막 Isar 쓰기 시간
      const updateInterval = Duration(milliseconds: 100);   // Isar 쓰기 최소 간격 (0.1초)

      // DB 저장을 처리하는 내부 헬퍼 함수
      Future<void> saveResponseToIsar(String textToSave) async {
        // message 변수를 기반으로 MessageModel을 생성하여 변수에 저장
        final responseModel = MessageModel(
          date: responseDate,   // 고정된 시간 사용
          isMine: false,
          message: textToSave,
        );

        final existingId = currentModelMessageId;   // 로컬 변수로 복사하면 타입 승격 작동

        // 이미 메시지를 생성한 적이 있다면 model 변수에 id 프로퍼티를 추가
        if (existingId != null) {
          responseModel.id = existingId;
        }

        // 메시지를 저장하고 받환받은 ID 값을 currentModelMessageId에 할당
        currentModelMessageId = await isar.writeTxn<int>(
          () => isar.messageModels.put(responseModel),
        );
        
        lastSavedMessage = textToSave;
        lastDbUpdate = DateTime.now();
      }

      // generateContentStream을 실행하면 Stream으로 응답 수신 가능
      // 위 listen 코드 대신 await for를 사용해 청크를 순서대로 안전하게 처리
      final responseStream = model.generateContentStream(promptContext);

      await for (final event in responseStream) {
        final chunk = event.text;

        if (chunk == null || chunk.isEmpty) continue;   // Thinking 단계 등에서 text가 null이거나 비어있으면 패스

        message += chunk;

        // 마지막 저장 후 100ms가 지났을 때만 Isar 업데이트 (쓰로틀링 최적화)
        if (DateTime.now().difference(lastDbUpdate) >= updateInterval) {
          await saveResponseToIsar(message);
        }
      }

      // Stream 종료 후, 100ms 간격 때문에 아직 저장되지 않은 마지막 잔여 텍스트가 있다면 최종 저장
      if (message.isNotEmpty && message != lastSavedMessage) {
        await saveResponseToIsar(message);
      }

      // Stream이 끝났는데도 받은 텍스트가 전혀 없는 경우 확인을 위한 로그
      if (message.isEmpty) {
        debugPrint('Warning : The stream has completed, but no text has been received');
      }
    } catch (e) {
      // 클로저 진입 전에 로컬 변수로 복사하거나 '!' 연산자 사용
      final userMsgId = currentUserMessageId;
      final modelMsgId = currentModelMessageId;
      
      // 에러 발생 시 Isar에서 내가 보낸 메시지 및 생성 중이던 AI 메시지 삭제
      await isar.writeTxn(() async {
        if (userMsgId != null) {
          await isar.messageModels.delete(userMsgId);
        }
        if (modelMsgId != null) {
          await isar.messageModels.delete(modelMsgId);
        }
      });

      // 사용자가 다시 입력하지 않도록 TextField에 원래 입력값 복원 및 커서 맨 끝 이동
      controller.text = currentPrompt;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );

      if (mounted) {
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

      debugPrint('Error : $e');
    } finally {
      // 성공하든 에러가 나든 Stream이 끝나면 로딩 상태 해제
      // 상태 변경 시 setState() 함수 실행
      // 값 변경 시 build() 함수 재실행
      // Clean -> setState() -> Dirty -> build() -> Clean
      if (mounted) {
        setState(() {
          isRunning = false;
        });
      }
    }
  }

  // 화면에 로고와 메시지들을 보여주는 ListView 함수
  Widget buildMessageList(List<MessageModel> messages) {
    return ListView.separated(
      controller: scrollController,   // 선언한 컨트롤러를 ListView에 입력
      itemBuilder: (context, index) => index == 0
        ? buildLogo()
        : buildMessageItem(
            message: messages[index - 1],
            prevMessage: index > 1 ? messages[index - 2] : null,
            index: index - 1,
          ),
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
      itemCount: messages.length + 1,
    );
  }

  // 로고를 보여줄 위젯
  Widget buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Padding(
        padding: EdgeInsets.only(bottom: 60.0),
        child: Logo(),
      ),
    );
  }

  // 메시지를 화면에 그리는 함수
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