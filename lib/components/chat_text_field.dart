import 'package:flutter/material.dart';

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;   // 입력값 추출을 위해 외부에서 직접 입력받는 controller
  final VoidCallback onSend;   // 전송 버튼을 눌렀을 때 실행할 함수
  final String? error;   // 에러 메시지가 있을 경우 입력받을 변수
  final bool loading;   // 로딩 중일 경우 전송 버튼 디자인 회색으로 변경 및 비활성화

  const ChatTextField({
    super.key,

    this.error,
    this.loading = false,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Colors.blueAccent,   // 커서색 변경
      minLines: 1,   // 입력 필드 최소 1줄
      maxLines: 4,   // 입력 필드 최대 4줄
      textAlignVertical: TextAlignVertical.center,   // 텍스트 필드 세로 중앙 정렬
      decoration: InputDecoration(
        errorText: error,
        // 텍스트 필드 전송 버튼
        suffixIcon: IconButton(
          onPressed: loading ? null : onSend,
          icon: Icon(
            Icons.send_outlined,
            color: loading ? Colors.grey : Colors.blueAccent,
          ),
        ),
        // 둥근 형태의 테두리 적용
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        // 텍스트 필드가 선택되어 있는 경우 테두리 색 변경
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(
            color: Colors.blueAccent,
            width: 2.0,
          ),
        ),
        hintText: 'Please enter a message!'
      ),
    );
  }
}