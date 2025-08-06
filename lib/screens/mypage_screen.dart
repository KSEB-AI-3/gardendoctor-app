import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

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
      final api = ApiService(dio);

      final User fetchedUser = await api.getUserMe();
      setState(() {
        _user = fetchedUser;
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = '사용자 정보를 불러오지 못했습니다. (${e.response?.statusCode ?? e.type.toString()})';
        _isLoading = false;
      });
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        _showSessionExpiredDialog();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '알 수 없는 오류 발생: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _changeNickname() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('닉네임 변경', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '새 닉네임 입력'),
          ),
          actions: [
            TextButton(
              child: Text('취소', style: GoogleFonts.gaegu(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('변경', style: GoogleFonts.gaegu(color: Color(0xFF2ECC71))),
              onPressed: () async {
                final newNickname = controller.text.trim();
                if (newNickname.isEmpty) return;
                Navigator.of(dialogContext).pop();
                try {
                  setState(() => _isLoading = true);
                  final dio = Dio();
                  final api = ApiService(dio);
                  final user = await api.updateNickname({"newNickname": newNickname});
                  setState(() {
                    _user = user;
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('닉네임이 변경되었습니다.', style: GoogleFonts.gaegu())),
                  );
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('닉네임 변경 실패', style: GoogleFonts.gaegu())),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    try {
      setState(() => _isLoading = true);
      final dio = Dio();
      final api = ApiService(dio);
      final file = File(image.path);
      final user = await api.uploadProfileImage(file);
      setState(() {
        _user = user;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 이미지가 변경되었습니다.', style: GoogleFonts.gaegu())),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 이미지 변경 실패', style: GoogleFonts.gaegu())),
      );
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      setState(() => _isLoading = true);
      final dio = Dio();
      final api = ApiService(dio);
      final user = await api.deleteProfileImage();
      setState(() {
        _user = user;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기본 프로필 이미지로 변경되었습니다.', style: GoogleFonts.gaegu())),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 이미지 삭제 실패', style: GoogleFonts.gaegu())),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('회원 탈퇴', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        content: Text('정말로 회원 탈퇴하시겠습니까? 이 작업은 취소할 수 없습니다.', style: GoogleFonts.gaegu()),
        actions: [
          TextButton(
            child: Text('취소', style: GoogleFonts.gaegu(color: Colors.grey)),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          TextButton(
            child: Text('탈퇴', style: GoogleFonts.gaegu(color: Colors.red)),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);
      final dio = Dio();
      final api = ApiService(dio);
      await api.deleteAccount();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원 탈퇴 실패', style: GoogleFonts.gaegu())),
      );
    }
  }

  Future<void> _logout() async {
    try {
      final dio = Dio();
      final api = ApiService(dio);
      await api.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('세션 만료', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
          content: Text('세션이 만료되었습니다. 다시 로그인해주세요.', style: GoogleFonts.gaegu()),
          actions: [
            TextButton(
              child: Text('확인', style: GoogleFonts.gaegu(color: const Color(0xFF2ECC71))),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout();
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
              if (_user != null) ...[
                // 프로필 이미지 썸네일
                if (_user!.profileImageUrl != null && _user!.profileImageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            _user!.profileImageUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey[200],
                              child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '프로필 이미지',
                              style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: _uploadProfileImage,
                                  child: Text('이미지 변경', style: GoogleFonts.gaegu()),
                                ),
                                TextButton(
                                  onPressed: _deleteProfileImage,
                                  child: Text('기본 이미지로', style: GoogleFonts.gaegu()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                _buildUserInfoRow(Icons.email, '이메일', _user!.email),
                _buildUserInfoRow(Icons.person, '닉네임', _user!.nickname),
                _buildUserInfoRow(Icons.badge, '역할', _user!.role),
                if (_user!.oauthProvider != null && _user!.oauthProvider!.isNotEmpty)
                  _buildUserInfoRow(Icons.login, 'OAuth 제공자', _user!.oauthProvider!),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text('닉네임 변경', style: GoogleFonts.gaegu()),
                      onPressed: _changeNickname,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF2ECC71)),
                title: Text("설정", style: GoogleFonts.gaegu()),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('설정 화면으로 이동합니다.', style: GoogleFonts.gaegu())),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF2ECC71)),
                title: Text("로그아웃", style: GoogleFonts.gaegu()),
                onTap: _logout,
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text("회원 탈퇴", style: GoogleFonts.gaegu(color: Colors.red)),
                onTap: _deleteAccount,
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
