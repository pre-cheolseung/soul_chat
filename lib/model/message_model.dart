class MessageModel {
  final DateTime date;   // 메시지 전송 날짜
  final int id;   // 메시지 ID
  final bool isMine;   // true : 내가 보낸 메시지, false : AI가 보낸 메시지
  final String message;   // 메시지 내용
  final int? point;   // 포인트 (AI 메시지의 경우 null)

  MessageModel({
    required this.date,
    required this.id,
    required this.isMine,
    required this.message,
    this.point,
  });
}