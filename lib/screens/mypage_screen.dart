import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ SharedPreferences 임포트

import '../models/user_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart'; // ✅ LoginScreen 임포트

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      final api = ApiService(dio); // 인터셉터는 ApiService 팩토리에서 추가됨

      final User fetchedUser = await api.getUserMe();
      setState(() {
        _user = fetchedUser;
        _isLoading = false;
      });
      print("사용자 정보 조회 성공: ${_user?.email}");
    } on DioException catch (e) {
      print("사용자 정보 조회 DioError: ${e.response?.statusCode} - ${e.response?.data}");
      setState(() {
        _errorMessage = '사용자 정보를 불러오지 못했습니다. (${e.response?.statusCode ?? e.type.toString()})';
        _isLoading = false;
      });
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        // 토큰 만료 또는 인증 실패 시 로그인 화면으로 리다이렉트
        _showSessionExpiredDialog();
      }
    } catch (e) {
      print("사용자 정보 조회 일반 오류: ${e.toString()}");
      setState(() {
        _errorMessage = '알 수 없는 오류 발생: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      final dio = Dio();
      final api = ApiService(dio); // 인터셉터는 ApiService 팩토리에서 추가됨

      // 서버에 로그아웃 요청 (Access Token이 자동으로 헤더에 추가됨)
      await api.logout();
      print("서버 로그아웃 요청 성공");

      // 로컬에 저장된 토큰 삭제
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      print("로컬 토큰 삭제 완료");

      // 로그인 화면으로 이동 (모든 이전 화면 제거)
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } on DioException catch (e) {
      print("로그아웃 DioError: ${e.response?.statusCode} - ${e.response?.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 실패: ${e.response?.data['message'] ?? e.response?.statusCode}')),
      );
      // 서버 로그아웃 실패해도 로컬 토큰은 지우고 로그인 화면으로 이동하는 것이 일반적
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("로그아웃 일반 오류: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류 발생: ${e.toString()}')),
      );
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 다이얼로그 외부를 탭하여 닫을 수 없게 함
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('세션 만료', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
          content: Text('세션이 만료되었습니다. 다시 로그인해주세요.', style: GoogleFonts.gaegu()),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: GoogleFonts.gaegu(color: const Color(0xFF2ECC71))),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                _logout(); // 로그아웃 처리 및 로그인 화면으로 이동
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("마이페이지", style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
              : _errorMessage != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_errorMessage!, style: GoogleFonts.gaegu(color: Colors.red)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('다시 시도', style: GoogleFonts.gaegu()),
                ),
              ],
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "내 정보",
                style: GoogleFonts.gaegu(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2ECC71),
                ),
              ),
              const SizedBox(height: 20),
              _user != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoRow(Icons.email, '이메일', _user!.email),
                  _buildUserInfoRow(Icons.person, '닉네임', _user!.nickname),
                  _buildUserInfoRow(Icons.badge, '역할', _user!.role),
                  // 추가 정보 (null이 아닐 경우만 표시)
                  if (_user!.profileImage != null && _user!.profileImage!.isNotEmpty)
                    _buildUserInfoRow(Icons.image, '프로필 이미지', _user!.profileImage!),
                  if (_user!.oauthProvider != null && _user!.oauthProvider!.isNotEmpty)
                    _buildUserInfoRow(Icons.login, 'OAuth 제공자', _user!.oauthProvider!),
                ],
              )
                  : Container(), // 사용자 정보가 없을 경우 빈 컨테이너
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF2ECC71)),
                title: Text("설정", style: GoogleFonts.gaegu()),
                onTap: () {
                  // 설정 화면으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('설정 화면으로 이동합니다.', style: GoogleFonts.gaegu())),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF2ECC71)),
                title: Text("로그아웃", style: GoogleFonts.gaegu()),
                onTap: _logout, // 로그아웃 함수 호출
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: GoogleFonts.gaegu(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.gaegu(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis, // 긴 텍스트 처리
            ),
          ),
        ],
      ),
    );
  }
}
