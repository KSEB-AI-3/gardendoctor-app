import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 기기 정보 확인을 위한 패키지 import
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

import '../models/user_model.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 서버 주소를 변수로 만들어 관리 용이성을 높입니다.
  final String _baseUrl = 'http://172.16.231.57:8080';

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_idController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar('이메일과 비밀번호를 입력해주세요.');
      return;
    }
    setState(() => _isLoading = true);
    final dio = Dio();
    final api = ApiService(dio);
    final request = LoginRequest(
      email: _idController.text.trim(),
      password: _passwordController.text.trim(),
    );
    try {
      final JwtToken token = await api.login(request);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token.accessToken);
      await prefs.setString('refreshToken', token.refreshToken);
      _showSnackBar('로그인 성공!', isSuccess: true);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      String errorMessage = '로그인 실패';
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? '서버 오류가 발생했습니다.';
      }
      _showSnackBar(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 구글 OAuth2 로그인
  Future<void> _signInWithGoogle() async {
    await _socialSignIn('google');
  }

  /// 카카오 OAuth2 로그인
  Future<void> _signInWithKakao() async {
    await _socialSignIn('kakao');
  }

  /// 소셜 로그인 공통 로직
  Future<void> _socialSignIn(String provider) async {
    setState(() => _isLoading = true);
    try {
      // 1. 기기 정보 가져오기
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = 'unknown';
      String deviceName = 'unknown';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_id';
        deviceName = iosInfo.model;
      }

      // 2. 백엔드 인증 URL 생성
      final originalUrl = Uri.parse('$_baseUrl/oauth2/authorization/$provider');
      final authUrl = originalUrl.replace(
        queryParameters: {
          ...originalUrl.queryParameters,
          // '액세스 차단' 오류 해결용 파라미터
          'device_id': deviceId,
          'device_name': deviceName,
          // 백엔드의 분기 로직 통과용 파라미터
          'redirect_uri': 'https://flutterwebauth.page.link/$provider'
        },
      ).toString();

      // 3. 웹뷰를 통해 인증 진행
      final resultUrl = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'gardendoctor',
      );

      // 4. 결과 URL에서 토큰 추출 및 저장
      final uri = Uri.parse(resultUrl);
      final accessToken = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (accessToken == null || refreshToken == null) {
        throw Exception('토큰이 반환되지 않았습니다.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);

      _showSnackBar('$provider 로그인 성공!', isSuccess: true);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showSnackBar('$provider 로그인 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.gaegu(color: Colors.white)),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI 부분은 기존과 동일하므로 변경 없습니다.
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text('텃밭 닥터', style: GoogleFonts.gaegu(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2ECC71))),
                      Text('스마트 농업의 시작', style: GoogleFonts.gaegu(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('로그인', style: GoogleFonts.gaegu(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)), textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _idController,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          hintText: 'example@email.com',
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2ECC71)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          labelStyle: GoogleFonts.gaegu(color: Colors.grey[700]),
                          hintStyle: GoogleFonts.gaegu(color: Colors.grey[500]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        style: GoogleFonts.gaegu(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          hintText: '비밀번호를 입력하세요',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2ECC71)),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          labelStyle: GoogleFonts.gaegu(color: Colors.grey[700]),
                          hintStyle: GoogleFonts.gaegu(color: Colors.grey[500]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        style: GoogleFonts.gaegu(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('로그인', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('또는', style: GoogleFonts.gaegu(color: Colors.grey[600], fontSize: 14)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('간편 로그인', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50))),
                      const SizedBox(height: 20),
                      _SocialLoginButton(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: Icons.g_mobiledata,
                        text: 'Google로 계속하기',
                        color: const Color(0xFFDB4437),
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 12),
                      _SocialLoginButton(
                        onPressed: _isLoading ? null : _signInWithKakao,
                        icon: Icons.chat_bubble,
                        text: 'Kakao로 계속하기',
                        color: const Color(0xFFFFE812),
                        textColor: const Color(0xFF3C1E1E),
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('아직 회원이 아니신가요? ', style: GoogleFonts.gaegu(color: Colors.grey[700], fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                      child: Text('회원가입', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold, color: const Color(0xFF2ECC71), fontSize: 16, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;
  final bool isLoading;

  // ✅✅✅ [수정] const 키워드를 삭제했습니다. ✅✅✅
  _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.color,
    this.textColor = Colors.white,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: textColor, strokeWidth: 2))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(text, style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
