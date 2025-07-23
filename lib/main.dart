import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; // 날짜 포맷을 위해 추가
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // Kakao SDK 임포트
import 'package:flutter_naver_login/flutter_naver_login.dart'; // 네이버 로그인 임포트 (초기화 메서드 제거)

import 'screens/home_screen.dart';

// 전역으로 카메라 리스트를 담을 변수 선언
late List<CameraDescription> cameras;

Future<void> main() async {
  // 카메라 초기화 및 SDK 초기화 전에 반드시 호출
  WidgetsFlutterBinding.ensureInitialized();

  // 날짜 데이터를 초기화하는 코드를 추가합니다.
  await initializeDateFormatting();

  // 사용 가능한 카메라 목록 가져오기
  cameras = await availableCameras();

  KakaoSdk.init(nativeAppKey: '9af0e924deb2e294b1875e7b9b2de45a');


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Bootcamp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2ECC71)),
        useMaterial3: true,
        textTheme: GoogleFonts.gaeguTextTheme(),
      ),
      home: const HomeScreen(), // 실제 앱의 시작 페이지로 변경하세요.
    );
  }
}

// 참고: MyHomePage는 예시였으므로, 기존의 HomeScreen을 그대로 사용합니다.
// HomeScreen 내에서 카카오 로그인 버튼을 구현하시면 됩니다.
