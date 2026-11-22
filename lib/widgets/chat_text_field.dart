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
    // 웜 라벤더 포인트 컬러
    const lavenderPrimary = Color(0xFF7C5DFA);
    const lavenderLight = Color(0xFF967EFB);
    const lavenderTintBg = Color(0xFFF7F5FF);   // 입력창 배경
    const lavenderBorder = Color(0xFFE6E0FF);   // 입력창 테두리
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
        // 에러 메시지 표시
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              bottom: 6.0
            ),
            child: Text(
              error!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12.0,
              ),
            ),
          ),

        // 전체를 하나로 감싸는 둥근 통합 캡슐 컨테이너
        Container(
          decoration: BoxDecoration(
            color: lavenderTintBg,
            borderRadius: BorderRadius.circular(26.0),
            border: Border.all(
              color: lavenderBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: lavenderPrimary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 5.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 선택된 파일이 있으면 캡슐 내부 상단에 미리보기 배치
              if (selectedFile != null) _buildFilePreview(selectedFile!),   // 선택된 파일 미리보기 위젯

              // 하단 입력 줄: [첨부 버튼] + [텍스트 입력창] + [전송 버튼]
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 왼쪽 파일 첨부(+) 버튼 (크기 고정)
                  SizedBox(
                    width: 36.0,
                    height: 36.0,
                    child: IconButton(
                      onPressed: loading ? null : onPickFile,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 22.0,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFEDE8FF),
                        foregroundColor: const Color(0xFF5A45B5),
                        shape: const CircleBorder(),
                      ),
                      tooltip: 'Attach file',
                    ),
                  ),

                  // 가운데 투명 텍스트 입력창 (배경색 제거해 캡슐과 일체화)
                  Expanded(
                    child: TextField(
                      controller: controller,
                      // onTap: onTap,   // 입력창을 누르면 키보드가 올라오는 타이밍에 맞춰 대화의 맨 아래로 이동
                      cursorColor: lavenderPrimary,   // 커서 색상
                      minLines: 1,   // 입력 필드 최소 1줄
                      maxLines: 4,   // 입력 필드 최대 4줄
                      // textAlignVertical: TextAlignVertical.center,   // 텍스트 필드 세로 중앙 정렬
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                        fontSize: 15.0,
                        height: 1.35,
                        color: Color(0xFF2D2254),
                      ),
                      decoration: InputDecoration(
                        hintText: selectedFile != null
                            ? 'Ask a question about the file!'
                            : 'Please enter a message!',
                        hintStyle: TextStyle(
                          color: Color(0xFFA59EC4),
                          fontSize: 15.0,
                        ),
                        isDense: true,
                        // 버튼과 수직 높이가 정확히 일치하도록 패딩 계산
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        border: InputBorder.none,   // 내부 테두리 완전 제거
                      ),
                    ),
                  ),

                  const SizedBox(width: 4.0),

                  // 오른쪽 전송 버튼 (크기 고정으로 왼쪽 버튼과 완벽하게 대칭)
                  SizedBox(
                    width: 36.0,
                    height: 36.0,
                    child: loading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: lavenderPrimary,
                          ),
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [lavenderLight, lavenderPrimary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: lavenderPrimary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onSend,
                              customBorder: const CircleBorder(),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 2.0),
                                  child: Icon(
                                    Icons.send_rounded,
                                    size: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 캡슐 내부 상단에 들어가는 선택된 파일 미리보기 위젯 (이미지 썸네일 vs 문서 배지 자동 분기)
  Widget _buildFilePreview(File file) {
    final isImage = _isImageFile(file.path);
    final fileName = file.path.split('/').last;   // 경로에서 파일명만 추출

    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 6.0,
        bottom: 4.0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFD6CCFF)),
            ),
            child: isImage
              // 이미지인 경우 64x64 썸네일 출력
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(11.0),
                  child: Image.file(
                    file,
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                  ),
                )
              // PDF 등 문서인 경우 파일 아이콘 + 이름 카드 출력
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.description_rounded,
                        size: 16.0,
                        color: Color(0xFF7C5DFA),
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
                            color: Color(0xFF2D2254),
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
            top: -5.0,
            right: -5.0,
            child: GestureDetector(
              onTap: onRemoveFile,
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3B8C),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 11.0,
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