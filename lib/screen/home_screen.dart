import 'dart:ui';   // ImageFilter.blur 사용

import 'package:flutter/material.dart';

import 'package:soul_chat/components/chat_text_field.dart';
import 'package:soul_chat/model/message_model.dart';
import 'package:soul_chat/service/chat_ai_service.dart';
import 'package:soul_chat/widget/message_list_view.dart';
import 'package:soul_chat/widget/scroll_to_bottom_button.dart';

import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';

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
  final _chatAiService = ChatAiService();   // 제미나이 AI 호출 로직 클래스
  bool showScrollToBottom = false;   // 맨 아래로 내리기 버튼 표시 여부 상태 변수
  bool isRunning = false;   // 로딩 여부를 확인하는 변수
  String? error;   // 에러 메시지 변수

  @override
  void initState() {
    super.initState();

    // 스크롤 위치가 바뀔 때마다 실행될 리스너 등록
    scrollController.addListener(_scrollListener);
  }

  // 스크롤 위치를 계산해 버튼을 보여줄지 숨길지 결정하는 함수
  void _scrollListener() {
    if (!scrollController.hasClients) return;

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    // 키보드가 올라와 있는 상태거나 화면 크기가 변하는 중에는 버튼 깜빡임 방지
    if (isKeyboardOpen) {
      if (showScrollToBottom) {
        setState(() => showScrollToBottom = false);
      }
      return;
    }

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    final shouldShow = (maxScroll - currentScroll) > 200;   // 맨 아래(maxScroll)에서 위로 200px 이상 올라갔을 때만 버튼 표시

    // 상태가 실제로 바뀔 때만 setState 호출 (스크롤 중 불필요한 화면 재빌드 방지)
    if (showScrollToBottom != shouldShow) {
      // 상태 변경 시 setState() 함수 실행
      // 값 변경 시 build() 함수 재실행
      // Clean -> setState() -> Dirty -> build() -> Clean
      setState(() {
        showScrollToBottom = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);   // 리스너 해제
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;   // 키보드가 올라와 있는지 확인

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),   // 채팅 빈 화면을 터치하면 키보드 내리기
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,   // 명시적으로 활성화 (기본값)
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   surfaceTintColor: Colors.transparent,   // 스크롤 시 앱바 색상이 변하는 현상 방지
        //   scrolledUnderElevation: 0,   // 스크롤 시 그림자 생김 방지
        //   elevation: 0,
        //   toolbarHeight: 48.0,   // 앱바 높이를 살짝 슬림하게 조절
        //   // 앱바와 채팅 목록 경계가 자연스럽도록 아주 옅은 구분선 추가
        //   bottom: PreferredSize(
        //     preferredSize: const Size.fromHeight(1.0),
        //     child: Container(
        //       color: Colors.grey.shade100,
        //       height: 1.0,
        //     ),
        //   ),
        //   actions: [
        //     IconButton(
        //       icon: const Icon(
        //         Icons.delete_outline,
        //         color: Colors.black87
        //       ),
        //       tooltip: 'Conversation Reset',
        //       onPressed: _handleClearChat,
        //     ),
        //   ],
        // ),
        // ListView와 TextField를 세로로 정렬
        body: SafeArea(
          // top: false,   // AppBar 사용 시 설정
          child: Column(
            children: [
              // 채팅 목록 + 맨 아래로 내리기 버튼 영역
              // ListView가 화면을 최대한으로 차지하도록 설정
              Expanded(
                child: Stack(
                  children: [
                    // 분리된 채팅 목록 위젯
                    StreamBuilder<List<MessageModel>>(
                      stream: _messageStream,   // 매번 새로 생성하지 않고 미리 만들어둔 변수 연결
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? [];
                        // ListView의 가장 아래로 이동하는 함수
                        // '맨 아래에 있을 때(버튼이 안 보일 때)'만 새 메시지에 맞춰 따라 하강
                        if (!showScrollToBottom) {
                          WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
                        }
                        // 화면에 로고와 메시지들을 보여주는 ListView 함수
                        return MessageListView(
                          scrollController: scrollController,
                          messages: messages,
                        );
                      },
                    ),
                    // 오른쪽 상단 대화 초기화 버튼 (배경 없이 깔끔하게 배치)
                    Positioned(
                      top: 8.0,
                      right: 12.0,
                      child: IconButton(
                        onPressed: _handleClearChat,
                        tooltip: 'Conversation Reset',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.8),   // 말풍선과 겹쳐도 잘 보이게 반투명 배경
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.black54,
                          size: 22.0,
                        ),
                      ),
                    ),
                    // 위로 스크롤했을 때만 나타나는 맨 아래로 내리기 버튼
                    // 다크 및 포인트 컬러 알약형 버튼 (텍스트 + 아이콘)
                    ScrollToBottomButton(
                      isVisible: showScrollToBottom,
                      onTap: scrollToBottom,
                    ),
                    // 깔끔한 원형 버튼 + 얇은 테두리 (ChatGPT 스타일)
                    // 가운데 배치는 left: 0, right: 0, child를 Center로 변경
                    // Positioned(
                    //   right: 16.0,
                    //   bottom: 16.0,
                    //   child: ScrollToBottomButton(
                    //     isVisible: showScrollToBottom,
                    //     onTap: scrollToBottom,
                    //   ),
                    // ),
                  ],
                ),
              ),
              // 하단 채팅 입력창 영역
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
                  // 입력창을 누르면 키보드가 올라오는 타이밍에 맞춰 대화의 맨 아래로 이동
                  // onTap: () {
                  //   Future.delayed(const Duration(milliseconds: 300), () {
                  //     scrollToBottom();
                  //   });
                  // },
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
    if (!scrollController.hasClients) return;
    
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
      scrollToBottom();   // 옛날 대화를 읽다가(버튼이 떠 있는 상태에서) 새 메시지를 전송했을 때 바로 맨 아래로 하강

      await _chatAiService.sendMessage(currentPrompt);   // 무거운 DB 및 AI 스트림 처리 서비스에 위임
    } catch (e) {
      // UI 복구 및 SnackBar 처리는 화면이 담당
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

  // 전체 삭제 확인 팝업 및 실행 함수
  Future<void> _handleClearChat() async {
    if (isRunning) return;   // AI가 응답을 생성하는 중에는 삭제 방지

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text(
          'All conversation history will be deleted and cannot be recovered.'
          '\nAre you sure you want to DELETE it?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _chatAiService.clearAllMessages();

      if (mounted) {
        setState(() {
          showScrollToBottom = false;   // 하단 이동 버튼 상태 초기화
        });
      }
    }
  }
}