import 'package:flutter/material.dart';

class ClearChatDialog extends StatelessWidget {
  const ClearChatDialog({super.key});

  // 외부에서 한 줄로 편하게 호출할 수 있는 정적 메서드
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const ClearChatDialog(),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: const Text(
        'Clear Chat History',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
          color: Color(0xFF140E29),
        ),
      ),
      content: const Text(
        'All conversation history will be deleted and cannot be recovered.'
        '\nAre you sure you want to DELETE it?',
        style: TextStyle(
          fontSize: 14.5,
          height: 1.45,
          color: Color(0xFF3A3256),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black54,
          ),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          child: const Text('DELETE'),
        ),
      ],
    );
  }
}