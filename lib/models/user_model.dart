import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String nickname;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nickname,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class JwtToken {
  final String accessToken;
  final String refreshToken;

  JwtToken({required this.accessToken, required this.refreshToken});

  factory JwtToken.fromJson(Map<String, dynamic> json) => _$JwtTokenFromJson(json);
  Map<String, dynamic> toJson() => _$JwtTokenToJson(this);
}

// ✅ User 모델 추가 (GET /auth/user/me 응답)
@JsonSerializable()
class User {
  final int userId;
  final String email;
  final String nickname;
  final String? profileImage; // nullable
  final String? oauthProvider; // nullable
  final String? oauthId; // nullable
  final String role;
  final String? fcmToken; // nullable
  final String? subscriptionStatus; // nullable

  User({
    required this.userId,
    required this.email,
    required this.nickname,
    this.profileImage,
    this.oauthProvider,
    this.oauthId,
    required this.role,
    this.fcmToken,
    this.subscriptionStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// ✅ AuthResponseDto 모델 추가 (로그아웃 등 일반 응답)
@JsonSerializable()
class AuthResponseDto {
  final String? accessToken; // nullable
  final String? refreshToken; // nullable
  final String message;
  final String? errorCode; // nullable
  final dynamic data; // 유연성을 위해 dynamic으로 설정

  AuthResponseDto({
    this.accessToken,
    this.refreshToken,
    required this.message,
    this.errorCode,
    this.data,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => _$AuthResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);
}
