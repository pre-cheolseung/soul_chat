# Soul Chat

Gemini AI chatbot app.

- Flutter 3.47.7
- Dart 3.13.5

## Preparation

- HTTP request
- REST API
- JSON
- Gemini API via Firebase
    - Key issuance
- Isar Database
    - Collection definition
    - Run the builder runner (dart run build_runner build)

## Key Components

- Gemini API via Firebase
- Isar Database
- DateDivider
- Model Class
- ListView
    - ScrollController
- StreamBuilder
- SnackBar

## Additional Components

- Localizations
- FilePicker
- AlertDialog
- DateFormat
- ClipRRect
- GestureDetector
- Divider
- InteractiveViewer
- Hero
- AdaptiveTextSelectionToolbar
- TextSelectionToolbarTextButton
- MarkdownBody
- InlineSyntax
- InlineParser
- Navigator
- Clipboard
- IntrinsicWidth
- MessageAttachment
- InkWell
- IgnorePointer
- AnimatedOpacity
- AnimationController
- List
- AnimatedBuilder
- Transform

## Plugin

- flutter_localizations
- file_picker: ^13.4.0
- firebase_ai: ^5.2.0
- firebase_app_check: ^0.5.2
- firebase_core: ^5.2.0
- flutter_markdown_plus: ^1.0.12
- get_it: ^9.3.0
- intl: ^0.20.3
- isar_community: 3.4.1
- isar_community_flutter_libs: 3.4.1
- mime: ^2.1.0
- open_filex: ^5.0.0
- path_provider: ^2.1.6
- build_runner: ^2.4.13
- flutter_lints: ^6.0.0
- isar_community_generator: 3.4.1

## Features

- Send and receive chat messages with Gemini AI
- Apply an animation where three dots wave until the AI answer generation starts
- Apply custom Korean Markdown parsing
- Attachments such as images or documents can be sent together
    - Preview available
    - Documents will open in the default viewer app
- Automatically update the screen whenever a message arrives
- Check dates using separator lines
- Check the send/receive time and point at the bottom of the message
- Use a button that appears only when scrolling to move to the bottom of the chat message list
- Partial copy and full copy using the text selection toolbar
- Clicking the delete button launches a notification dialog in the custom material format
- Press the delete button in the dialog to remove the chat message history

## 기능

- 제미나이 AI와 채팅 메시지 송수신
- AI 답변 생성 시작 전까지 점 3개가 물결치듯 움직이는 애니메이션 적용
- 한국어 마크다운 커스텀 파싱 적용
- 이미지 또는 문서 등의 첨부파일 함께 전송 가능
    - 미리 보기 가능
    - 문서는 기본 뷰어 앱으로 연결
- 메시지가 들어올 때마다 자동으로 화면 업데이트
- 구분선을 통해 날짜 확인
- 메시지 하단에 송수신 시간 및 포인트 확인
- 스크롤을 올릴 때만 노출되는 버튼을 눌러서 채팅 메시지 최하단으로 이동
- 텍스트 선택 툴바를 통해 부분 복사 및 전체 복사
- 삭제 버튼을 누르면 커스텀 한 머터리얼 형식의 알림 다이얼로그 실행
- 다이얼로그의 삭제 버튼을 눌러서 채팅 메시지 내역 삭제