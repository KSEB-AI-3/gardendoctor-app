  import 'package:flutter/material.dart';
  import 'package:camera/camera.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:intl/date_symbol_data_local.dart'; // 날짜 포맷
  import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // 카카오 로그인 SDK
  import 'package:kakao_map_plugin/kakao_map_plugin.dart'; // 카카오 지도 플러그인

  import 'screens/home_screen.dart';

  // 전역으로 카메라 리스트를 담을 변수 선언
  late List<CameraDescription> cameras;

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 날짜 데이터 초기화
    await initializeDateFormatting();

    // 사용 가능한 카메라 목록 가져오기
    cameras = await availableCameras();

    // 카카오 로그인 SDK 초기화 (로그인/유저정보)
    KakaoSdk.init(nativeAppKey: '9af0e924deb2e294b1875e7b9b2de45a');

    // ⭐️ 카카오 지도 SDK(appKey는 카카오 JavaScript키!) 초기화 (최초 1회)
    AuthRepository.initialize(appKey: 'cde65291e9efcf578d4e69a98509a646'); // 예: 'e7ac3b1c53abbd1e7bfe56e50a193289'

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
        home: const HomeScreen(),
      );
    }
  }