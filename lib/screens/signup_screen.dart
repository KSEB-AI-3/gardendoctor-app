import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // ✅ _idController (username) 삭제 또는 emailController로 통합
  // final _idController = TextEditingController(); // 삭제하거나 emailController로 대체
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  // final _addressController = TextEditingController(); // 삭제
  // bool _idChecked = false; // 삭제
  bool _nicknameChecked = false;
  // String? _gender; // 삭제

  // ✅ _checkIdDuplicate 삭제 또는 email 중복 확인으로 변경
  // Future<void> _checkIdDuplicate() async {
  //   if (_idController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('아이디를 먼저 입력해주세요.')),
  //     );
  //     return;
  //   }
  //   await Future.delayed(const Duration(seconds: 1));
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('사용 가능한 아이디입니다.')),
  //     );
  //     setState(() => _idChecked = true);
  //   }
  // }

  Future<void> _checkNicknameDuplicate() async {
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 먼저 입력해주세요.')),
      );
      return;
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용 가능한 닉네임입니다.')),
      );
      setState(() => _nicknameChecked = true);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // ✅ 유효성 검사 조건 변경: _idChecked, _gender, _address 제거
      if (!_nicknameChecked) { // _idChecked 대신 email 중복 확인 필요시 추가
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 확인 절차를 완료해주세요.')),
        );
        return;
      }

      final dio = Dio();
      final api = ApiService(dio);

      final request = RegisterRequest(
        // username: _idController.text.trim(), // 삭제
        password: _passwordController.text.trim(),
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        // gender: _gender!, // 삭제
        // address: _addressController.text.trim(), // 삭제
      );

      try {
        print("회원가입 요청 시작: ${DateTime.now()}");
        print("요청 데이터: ${request.toJson()}");

        await api.register(request);
        print("회원가입 요청 완료: ${DateTime.now()}");

        final loginRequest = LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        print("자동 로그인 시도");
        final loginResponse = await api.login(loginRequest);
        print("로그인 응답: ${loginResponse.accessToken}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다!')),
        );
        Navigator.pop(context);
      } catch (e) {
        print("회원가입 중 예외 발생: ${e.runtimeType}");
        if (e is DioException) {
          print("DioError 발생: ${e.message}");
          print("DioError 타입: ${e.type}");
          if (e.response != null) {
            print("응답 상태 코드: ${e.response?.statusCode}");
            print("응답 데이터: ${e.response?.data}");
            // ✅ 스낵바 메시지 개선: 상태 코드와 함께 출력
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '서버 오류: 상태 코드 ${e.response?.statusCode ?? '알 수 없음'}${e.response?.data != null ? '\n데이터: ${e.response?.data}' : '\n응답 데이터 없음'}'
                ),
              ),
            );
          } else {
            print("DioError: 서버 응답 없음 (네트워크 문제 또는 서버 다운)");
            print("DioError 상세: ${e.error}");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('서버와 연결 실패 또는 응답 없음')),
            );
          }
        } else {
          print("알 수 없는 회원가입 실패: ${e.toString()}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입 실패: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // _idController.dispose(); // 삭제
    _nicknameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emailController.dispose();
    // _addressController.dispose(); // 삭제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ 아이디 필드 삭제 또는 이메일 필드로 대체
              // _buildTextFieldWithButton(
              //   controller: _idController,
              //   labelText: '아이디',
              //   hintText: '영문, 숫자 포함 6~12자',
              //   buttonText: '중복확인',
              //   onPressed: _checkIdDuplicate,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) return '아이디를 입력해주세요.';
              //     if (value.length < 6) return '6자 이상 입력해주세요.';
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 16),
              _buildTextFieldWithButton(
                controller: _nicknameController,
                labelText: '닉네임',
                hintText: '2~8자',
                buttonText: '중복확인',
                onPressed: _checkNicknameDuplicate,
                validator: (value) {
                  if (value == null || value.isEmpty) return '닉네임을 입력해주세요.';
                  if (value.length < 2) return '2자 이상 입력해주세요.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                labelText: '비밀번호',
                hintText: '영문, 숫자, 특수문자 포함 8자 이상',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
                  if (value.length < 8) return '8자 이상 입력해주세요.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordConfirmController,
                labelText: '비밀번호 확인',
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) return '비밀번호가 일치하지 않습니다.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                labelText: '이메일',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                  if (!value.contains('@') || !value.contains('.')) return '유효한 이메일 형식이 아닙니다.';
                  return null;
                },
              ),
              // ✅ 사는 곳 (주소) 필드 삭제
              // const SizedBox(height: 16),
              // _buildTextField(
              //   controller: _addressController,
              //   labelText: '사는 곳 (시/군/구)',
              //   hintText: '예: 서울시 강남구',
              //   validator: (value) => value == null || value.isEmpty ? '사는 곳을 입력해주세요.' : null,
              // ),
              // ✅ 성별 필드 삭제
              // const SizedBox(height: 24),
              // Text('성별', style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold)),
              // Row(
              //   children: [
              //     Expanded(
              //       child: RadioListTile<String>(
              //         title: Text('남성', style: GoogleFonts.gaegu()),
              //         value: 'male',
              //         groupValue: _gender,
              //         onChanged: (value) => setState(() => _gender = value),
              //       ),
              //     ),
              //     Expanded(
              //       child: RadioListTile<String>(
              //         title: Text('여성', style: GoogleFonts.gaegu()),
              //         value: 'female',
              //         groupValue: _gender,
              //         onChanged: (value) => setState(() => _gender = value),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('가입하기', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: GoogleFonts.gaegu(),
        hintStyle: GoogleFonts.gaegu(),
      ),
      validator: validator,
      style: GoogleFonts.gaegu(),
    );
  }

  Widget _buildTextFieldWithButton({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String buttonText,
    required VoidCallback onPressed,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelStyle: GoogleFonts.gaegu(),
              hintStyle: GoogleFonts.gaegu(),
            ),
            validator: validator,
            style: GoogleFonts.gaegu(),
            onChanged: (value) {
              // if (labelText == '아이디') setState(() => _idChecked = false); // 삭제
              if (labelText == '닉네임') setState(() => _nicknameChecked = false);
            },
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Text(buttonText, style: GoogleFonts.gaegu()),
          ),
        ),
      ],
    );
  }
}
