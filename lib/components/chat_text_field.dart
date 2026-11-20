import 'dart:io';

import 'package:flutter/material.dart';

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;   // 입력값 추출을 위해 외부에서 직접 입력받는 controller
  final VoidCallback onSend;   // 전송 버튼을 눌렀을 때 실행할 함수
  // final VoidCallback? onTap;   // 입력창을 누르면 키보드가 올라오는 타이밍에 맞춰 대화의 맨 아래로 이동
  final VoidCallback onPickFile;   // 파일 첨부 버튼 클릭
  final VoidCallback onRemoveFile;   // 미리보기 X 버튼 클릭
  final File? selectedFile;   // 현재 선택된 파일
  final String? error;   // 에러 메시지가 있을 경우 입력받을 변수
  final bool loading;   // 로딩 중일 경우 전송 버튼 디자인 회색으로 변경 및 비활성화

  const ChatTextField({
    super.key,

    required this.controller,
    required this.onSend,
    // this.onTap,
    required this.onPickFile,
    required this.onRemoveFile,
    this.selectedFile,
    this.error,
    this.loading = false,
  });

  // 파일 확장자가 이미지인지 판별하는 함수
  bool _isImageFile(String path) {
    final lower = path.toLowerCase();

    return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    // return TextField(
    //   controller: controller,
    //   // onTap: onTap,   // 입력창을 누르면 키보드가 올라오는 타이밍에 맞춰 대화의 맨 아래로 이동
    //   cursorColor: Colors.blueAccent,   // 커서색 변경
    //   minLines: 1,   // 입력 필드 최소 1줄
    //   maxLines: 4,   // 입력 필드 최대 4줄
    //   textAlignVertical: TextAlignVertical.center,   // 텍스트 필드 세로 중앙 정렬
    //   decoration: InputDecoration(
    //     errorText: error,
    //     // 텍스트 필드 전송 버튼
    //     suffixIcon: IconButton(
    //       onPressed: loading ? null : onSend,
    //       icon: Icon(
    //         Icons.send_outlined,
    //         color: loading ? Colors.grey : Colors.blueAccent,
    //       ),
    //     ),
    //     // 둥근 형태의 테두리 적용
    //     border: OutlineInputBorder(
    //       borderRadius: BorderRadius.circular(32.0),
    //     ),
    //     // 텍스트 필드가 선택되어 있는 경우 테두리 색 변경
    //     focusedBorder: OutlineInputBorder(
    //       borderRadius: BorderRadius.circular(32.0),
    //       borderSide: BorderSide(
    //         color: Colors.blueAccent,
    //         width: 2.0,
    //       ),
    //     ),
    //     hintText: 'Please enter a message!'
    //   ),
    // );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 선택된 파일이 있을 때만 입력창 바로 위에 미리보기 표시
        if (selectedFile != null) _buildFilePreview(selectedFile!),   // 선택된 파일 미리보기 위젯

        // 에러 메시지 표시
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              bottom: 6.0
            ),
            child: Text(
              error!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12.0
              ),
            ),
          ),

        // 파일 첨부 버튼 + 텍스트 입력 필드 + 전송 버튼
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 파일 첨부(+) 버튼
            IconButton(
              onPressed: loading ? null : onPickFile,
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: Colors.black54,
              iconSize: 26.0,
              tooltip: 'Attach file',
            ),
            // 텍스트 입력 필드
            Expanded(
              child: TextField(
                controller: controller,
                // onTap: onTap,   // 입력창을 누르면 키보드가 올라오는 타이밍에 맞춰 대화의 맨 아래로 이동
                // cursorColor: Colors.blueAccent,   // 커서색 변경
                minLines: 1,   // 입력 필드 최소 1줄
                maxLines: 4,   // 입력 필드 최대 4줄
                // textAlignVertical: TextAlignVertical.center,   // 텍스트 필드 세로 중앙 정렬
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: selectedFile != null
                    ? 'Ask a question about the file!'
                    : 'Please enter a message!',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15.0
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F8),
                  // 둥근 형태의 테두리 적용
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6.0),
            // 전송 버튼 (로딩 중일 때는 인디케이터 표시)
            loading
              ? const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                )
              : IconButton(
                  onPressed: onSend,
                  icon: const Icon(Icons.arrow_upward_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                  ),
                ),
          ],
        ),
      ],
    );
  }

  // 선택된 파일 미리보기 위젯 (이미지 썸네일 vs 문서 배지 자동 분기)
  Widget _buildFilePreview(File file) {
    final isImage = _isImageFile(file.path);
    final fileName = file.path.split('/').last;   // 경로에서 파일명만 추출

    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
        bottom: 8.0
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: isImage
              // 이미지인 경우 64x64 썸네일 출력
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(11.0),
                  child: Image.file(
                    file,
                    width: 64.0,
                    height: 64.0,
                    fit: BoxFit.cover,
                  ),
                )
              // PDF 등 문서인 경우 파일 아이콘 + 이름 카드 출력
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 20.0,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6.0),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180.0),
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
          // 우측 상단 첨부 취소(X) 버튼
          Positioned(
            top: -6.0,
            right: -6.0,
            child: GestureDetector(
              onTap: onRemoveFile,
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}