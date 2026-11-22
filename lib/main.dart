import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:soul_chat/models/message_model.dart';
import 'package:soul_chat/screens/home_screen.dart';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();   // 플러터 프레임워크가 앱을 실행할 준비가 될 때까지 대기

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);   // 화면 전체(Edge-to-Edge) 영역까지 앱이 그려지도록 설정
  // 상단 상태바 및 하단 내비게이션바 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,   // 상단 상태바 투명
      // statusBarIconBrightness: Brightness.light,   // 상단 상태바 아이콘 색상 (밝게: light, 어둡게: dark)
      systemNavigationBarColor: Colors.transparent,   // 하단 내비게이션바 투명
      systemNavigationBarDividerColor: Colors.transparent,   // 하단 구분선 제거
      // systemNavigationBarIconBrightness: Brightness.light,   // 하단 내비게이션바 아이콘 색상 (밝게: light, 어둡게: dark)
    ),
  );
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);   // 상단 상태바 및 하단 내비게이션바 숨김

  final dir = await getApplicationDocumentsDirectory();   // 앱에 배정된 폴더 경로 변수
  // Isar 데이터베이스 초기화
  final isar = await Isar.open(
    [MessageModelSchema],
    directory: dir.path,
  );

  GetIt.I.registerSingleton<Isar>(isar);   // GetIt에 Isar를 주입해서 프로젝트 어디에서든 사용

  // 플랫폼별 설정으로 Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 개발(디버그) 테스트용 App Check 활성화
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
      ? const AndroidDebugProvider()
      : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
      ? const AppleDebugProvider()
      : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,   // 우측 상단 DEBUG 빨간색 배너 삭제
      // 기본 언어 델리게이트 등록 (Material, Widgets, Cupertino 모두 한국어화)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 지원할 언어 목록에 한국어('ko') 추가
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      // locale: const Locale('ko', 'KR'),   // 기기 언어 설정과 무관하게 무조건 한국어로 고정하고 싶을 경우 추가
      home: HomeScreen(),
    ),
  );
}