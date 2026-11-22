import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:soul_chat/models/message_model.dart';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';
import 'package:mime/mime.dart';

class ChatAiService {
  final Isar _isar = GetIt.I<Isar>();   // Isar 인스턴스 변수

  Future<void> sendMessage(String prompt, {File? file}) async {   // 선택적 파라미터 File? file
    int? currentModelMessageId;
    int? currentUserMessageId;

    try {
      // 현재 데이터베이스에 저장되어 있는 내가 보낸 메시지 수 (포인트용)
      final myMessagesCount = await _isar.messageModels.filter().isMineEqualTo(true).count();

      // 파일이 있다면 MIME 타입 추출 (image/png, application/pdf 등)
      final String? mimeType = file != null
        ? (lookupMimeType(file.path) ?? 'application/octet-stream')
        : null;

      // 내가 보낸 메시지(텍스트 + 파일 경로)를 Isar에 저장
      currentUserMessageId = await _isar.writeTxn(() async {
        return await _isar.messageModels.put(
          MessageModel(
            date: DateTime.now(),
            isMine: true,
            message: prompt,
            point: myMessagesCount + 1,
            filePath: file?.path,
            mimeType: mimeType,
          ),
        );
      });

      // 최근 10개의 메시지 조회 및 변환 (방금 저장한 prompt 포함)
      // 제미나이에게 현재까지 대화한 문맥을 제공
      // 최근 어느 정도 대화 히스토리를 함께 제공하는 것이 정확한 대답을 이끌어내기에 유용
      // 많은 대화 히스토리를 제공할 수록 비용 증가
      // 날짜 내림차순으로 내용이 비어있는 잘못된 메시지를 제외한 가장 최근 10개 메시지 변수에 저장 (최신순: 10 -> 9 -> ... -> 2 -> 1)
      // final contextMessages = await isar.messageModels.where().limit(10).findAll();
      final contextMessages = await _isar.messageModels.where().sortByDateDesc().limit(10).findAll();
      
      final List<Content> promptContext = [];

      // 대화 문맥(Content) 구성 시 파일이 있는 메시지는 InlineDataPart 함께 포함
      // 텍스트와 첨부파일을 모두 담아서 아래 generateContentStream(promptContext)로 전달
      // 제미나이가 대화 흐름을 이해할 수 있도록 시간순으로 뒤집어서 변환 (과거 -> 최신)
      for (final e in contextMessages.reversed) {
        final List<Part> parts = [];

        // 첨부파일이 존재하고 실제 기기에 파일이 남아있다면 바이트 데이터 추가
        if (e.filePath != null && e.mimeType != null) {
          final savedFile = File(e.filePath!);

          if (await savedFile.exists()) {
            final bytes = await savedFile.readAsBytes();

            parts.add(InlineDataPart(e.mimeType!, bytes));
          }
        }

        // 텍스트가 있다면 TextPart 추가
        if (e.message.isNotEmpty) {
          parts.add(TextPart(e.message));
        }

        if (parts.isNotEmpty) {
          promptContext.add(Content(e.isMine ? 'user' : 'model', parts));
        }
      }
      
      // 사용할 제미나이 모델 인스턴스 초기화 (Gemini Developer API 기준)
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3.5-flash-lite',
        generationConfig: GenerationConfig(
          // 내부 추론(thinkingLevel)을 최소화로 설정하여 빠른 답변 시작
          thinkingConfig: ThinkingConfig.withThinkingLevel(ThinkingLevel.minimal),
          // maxOutputTokens: 500,   // 답변 길이를 적당히 제한하여 생성 시간 단축
          // 0.7~0.9 사이로 높이면 말투가 더 다채롭고 자연스러워짐
          // 환불을 원하는 고객에게 응대하는 경우 0.2 ~ 0.4
          temperature: 0.8,
        ),
        systemInstruction: Content.system(
          '당신은 착하고 친절한 단짝 친구입니다. '
          '항상 따뜻하고 긍정적인 말투로 공감해 주고, '
          '단답형 대신 2~3문장 정도로 다정하게 대답하며 대화가 이어질 수 있도록 가벼운 질문도 함께 건네주세요.'
        ),
        // 환불을 원하는 고객에게 응대하는 경우 temperature 함께 변경
        // systemInstruction: Content.system(
        //   '당신은 친절하고 전문적인 고객지원(CS) 환불 전담 상담원입니다. '
        //   '환불을 요청하는 고객의 불편함에 깊이 공감하고, 아래 원칙과 절차에 따라 명확하고 정중하게 응대하세요.\n\n'
        //   '[응대 원칙]\n'
        //   '1. 공감과 사과: 고객이 겪은 불편이나 아쉬움에 대해 먼저 진심으로 공감하고 정중히 사과합니다.\n'
        //   '2. 간결하고 구조화된 안내: 긴 줄글 대신 번호 목록이나 굵은 글씨(**강조**)를 사용해 핵심 절차만 한눈에 보기 쉽게 전달합니다.\n'
        //   '3. 정확한 정보 확인: 환불 처리를 위해 필요한 정보(주문번호, 구매 일자, 환불 사유 등)를 한 번에 2~3가지 이내로 정중히 요청합니다.\n'
        //   '4. 환각 및 임의 약속 금지: 확인되지 않은 환불 규정, 예외 승인, 임의의 보상안을 절대 스스로 지어내거나 약속하지 마세요. '
        //   '규정 외 예외 처리나 최종 승인이 필요한 경우 "담당 부서 확인 후 신속히 안내해 드리겠습니다"라고 안내하세요.\n'
        //   '5. 감정적 대응 자제: 고객이 화를 내거나 강한 어조를 사용하더라도 항상 차분하고 공손한 존댓말을 유지합니다.\n\n'
        //   '[자사 환불 규정]\n'
        //   '1. 단순 변심: 수령 후 7일 이내 미개봉 시 전액 환불 (왕복 배송비 6,000원 고객 부담)\n'
        //   '2. 상품 불량 및 오배송: 수령 후 30일 이내 100% 무료 환불\n\n'
        //   '[사진 첨부 기능 활용 유도]\n'
        //   '상품 파손이나 오배송으로 인한 환불인 경우, '
        //   '채팅창 왼쪽의 (+) 버튼을 눌러 사진이나 영수증을 첨부해 주시면 더 빠르게 도와드릴 수 있다고 안내하세요.'
        // ),
      );

      String message = '';   // Stream으로 받아지는 메시지를 지속적으로 추가할 문자열
      String lastSavedMessage = '';   // 마지막으로 Isar에 저장된 텍스트 추적용
      final responseDate = DateTime.now();    // 응답 시작 시간을 루프 밖에서 고정
      DateTime lastDbUpdate = DateTime.fromMillisecondsSinceEpoch(0);   // 마지막 Isar 쓰기 시간
      const updateInterval = Duration(milliseconds: 100);   // Isar 쓰기 최소 간격 (0.1초)

      // Isar 저장을 처리하는 내부 헬퍼 함수
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
        currentModelMessageId = await _isar.writeTxn<int>(
          () => _isar.messageModels.put(responseModel),
        );

        lastSavedMessage = textToSave;
        lastDbUpdate = DateTime.now();
      }

      // generateContentStream을 실행하면 Stream으로 응답 수신 가능
      // listen 대신 await for를 사용해 청크를 순서대로 안전하게 처리
      final responseStream = model.generateContentStream(promptContext);

      await for (final event in responseStream) {
        final chunk = event.text;

        if (chunk == null || chunk.isEmpty) continue;   // Thinking 단계 등에서 text가 null이거나 비어있으면 패스

        message += chunk;

        // 마지막 저장 후 100ms가 지났을 때만 Isar 업데이트 (스로틀링 최적화)
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
      // 에러 발생 시 Database 롤백 후 에러를 호출부(UI)로 다시 던짐(Rethrow)
      // 클로저 진입 전에 로컬 변수로 복사하거나 '!' 연산자 사용
      final userMsgId = currentUserMessageId;
      final modelMsgId = currentModelMessageId;

      // 에러 발생 시 Isar에서 내가 보낸 메시지 및 생성 중이던 AI 메시지 삭제
      await _isar.writeTxn(() async {
        if (userMsgId != null) await _isar.messageModels.delete(userMsgId);
        if (modelMsgId != null) await _isar.messageModels.delete(modelMsgId);
      });

      rethrow;   // UI에서 SnackBar와 입력창 복원을 처리할 수 있도록 에러 전달
    }
  }

  Future<void> clearAllMessages() async {
    await _isar.writeTxn(() async {
      await _isar.messageModels.clear();   // 컬렉션의 모든 메시지 삭제
    });
  }
}