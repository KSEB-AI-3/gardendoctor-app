import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:io';

part 'api_service.g.dart';

@RestApi(baseUrl: "http://172.16.231.57:8080")
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) {
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
        if (!['/auth/register', '/auth/login'].contains(path)) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? accessToken = prefs.getString('accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        return handler.next(options);
      },
    ));
    return _ApiService(dio, baseUrl: baseUrl);
  }

  // 로그인/회원가입/로그아웃 (기존)
  @POST("/auth/register")
  Future<void> register(@Body() RegisterRequest request);

  @POST("/auth/login")
  Future<JwtToken> login(@Body() LoginRequest request);

  @POST("/auth/logout")
  Future<AuthResponseDto> logout();

  // 내 정보 조회
  @GET("/auth/user/me")
  Future<User> getUserMe();

  // 닉네임 변경
  @PATCH("/auth/me/nickname")
  Future<User> updateNickname(@Body() Map<String, dynamic> body);

  // 프로필 이미지 업로드
  @PATCH("/auth/me/profile-image/upload")
  @MultiPart()
  Future<User> uploadProfileImage(@Part(name: "image") File image);

  // 프로필 이미지 삭제(기본 이미지로 복원)
  @DELETE("/auth/me/profile-image")
  Future<User> deleteProfileImage();

  // 회원 탈퇴
  @DELETE("/auth/me")
  Future<void> deleteAccount();
}
