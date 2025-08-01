import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "http://172.16.183.114:8080")
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) {

    // ✅✅✅ 이 부분이 빠져있었습니다. 타임아웃 설정을 추가합니다. ✅✅✅
    dio.options.connectTimeout = const Duration(seconds: 10); // 연결 타임아웃: 10초
    dio.options.receiveTimeout = const Duration(seconds: 10); // 응답 타임아웃: 10초
    // ✅✅✅ 여기까지 추가 ✅✅✅

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;

        // 회원가입과 로그인 경로는 토큰 추가 로직에서 제외
        if (path != '/auth/register' && path != '/auth/login') {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? accessToken = prefs.getString('accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
            print('✅ Access Token 추가됨: $accessToken');
          }
        }

        print('➡️ 요청: ${options.method} ${options.path}');
        print('➡️ 헤더: ${options.headers}');
        print('➡️ 데이터: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('⬅️ 응답: ${response.statusCode} ${response.requestOptions.path}');
        print('⬅️ 응답 데이터: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('❌ Dio 오류: ${e.requestOptions.path}');
        print('❌ 오류 메시지: ${e.message}');
        if (e.response != null) {
          print('❌ 오류 상태 코드: ${e.response?.statusCode}');
          print('❌ 오류 응답 데이터: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
    return _ApiService(dio, baseUrl: baseUrl);
  }

  @POST("/auth/register")
  Future<void> register(@Body() RegisterRequest request);

  @POST("/auth/login")
  Future<JwtToken> login(@Body() LoginRequest request);

  @GET("/auth/user/me")
  Future<User> getUserMe();

  @POST("/auth/logout")
  Future<AuthResponseDto> logout();
}