import 'package:flutter/material.dart';

import 'package:soul_chat/components/logo.dart';
import 'package:soul_chat/model/message_model.dart';

final sampleData = [
  MessageModel(
    date: DateTime(2026, 11, 17),
    id: 1,
    isMine: true,
    message: '오늘 저녁으로 먹을 만한 메뉴 추천해줘!',
    point: 1,
  ),
  MessageModel(
    date: DateTime(2026, 11, 17),
    id: 2,
    isMine: false,
    message: '칼칼한 김치찜은 어때요?!',
    point: null,
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);   // const 생성자 : 최초 선언 후 변경 불가능한 빌드 타임 함수

  @override
  // State<HomeScreen> createState() => _HomeScreenState();
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Widget buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Padding(
        padding: EdgeInsets.only(bottom: 60.0),
        child: Logo(),
      ),
    );
  }
}