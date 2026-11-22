import 'package:isar_community/isar.dart';

part 'message_model.g.dart';

@collection
class MessageModel {
  DateTime date;   // 메시지 전송 날짜
  bool isMine;   // true : 내가 보낸 메시지, false : AI가 보낸 메시지
  String message;   // 메시지 내용
  Id id =  Isar.autoIncrement;   // 메시지 ID
  int? point;   // 포인트 (AI 메시지의 경우 null)
  // 첨부된 파일의 로컬 경로 및 MIME 타입 ('image/jpeg', 'application/pdf' 등)
  String? filePath;
  String? mimeType;

  MessageModel({
    required this.date,
    required this.isMine,
    required this.message,
    this.id = Isar.autoIncrement,
    this.point,
    this.filePath,
    this.mimeType,
  });
}