import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerService {
  // 허용할 파일 확장자 목록을 한곳에서 관리
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'pdf',
    'txt',
  ];

  // 기기에서 파일을 선택해 File 객체로 반환 (취소 시 null 반환)
  Future<File?> pickAttachment() async {
    final pickedFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (pickedFile != null && pickedFile.path != null) {
      return File(pickedFile.path!);
    }
    
    return null;
  }
}