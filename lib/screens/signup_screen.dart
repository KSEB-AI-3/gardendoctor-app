import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // 각 입력 필드를 위한 컨트롤러
  final _idController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // 중복 확인 상태
  bool _idChecked = false;
  bool _nicknameChecked = false;

  // 성별 선택
  String? _gender;

  // 아이디 중복 확인 (서버 연동 시 실제 로직 구현 필요)
  Future<void> _checkIdDuplicate() async {
    if (_idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디를 먼저 입력해주세요.')),
      );
      return;
    }
    // 임시로 1초 후 성공 메시지를 보여줍니다.
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용 가능한 아이디입니다.')),
      );
      setState(() {
        _idChecked = true;
      });
    }
  }

  // 닉네임 중복 확인 (서버 연동 시 실제 로직 구현 필요)
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
      setState(() {
        _nicknameChecked = true;
      });
    }
  }

  // 회원가입 제출
  void _submitForm() {
    // Form 위젯의 유효성 검사를 실행
    if (_formKey.currentState!.validate()) {
      // 중복 확인을 했는지 체크
      if (!_idChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아이디 중복 확인을 해주세요.')),
        );
        return;
      }
      if (!_nicknameChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임 중복 확인을 해주세요.')),
        );
        return;
      }
      if (_gender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('성별을 선택해주세요.')),
        );
        return;
      }

      // TODO: 서버로 회원가입 정보 전송 로직 구현

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다!')),
      );
      Navigator.pop(context); // 회원가입 성공 후 이전 화면으로 돌아가기
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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
              // 아이디 입력 필드
              _buildTextFieldWithButton(
                controller: _idController,
                labelText: '아이디',
                hintText: '영문, 숫자 포함 6~12자',
                buttonText: '중복확인',
                onPressed: _checkIdDuplicate,
                validator: (value) {
                  if (value == null || value.isEmpty) return '아이디를 입력해주세요.';
                  if (value.length < 6) return '6자 이상 입력해주세요.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 닉네임 입력 필드
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
              // 비밀번호 입력 필드
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
              // 비밀번호 확인 필드
              _buildTextField(
                controller: _passwordConfirmController,
                labelText: '비밀번호 확인',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return '비밀번호를 다시 입력해주세요.';
                  if (value != _passwordController.text) return '비밀번호가 일치하지 않습니다.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 이메일 입력 필드
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
              const SizedBox(height: 16),
              // 사는 곳 입력 필드
              _buildTextField(
                controller: _addressController,
                labelText: '사는 곳 (시/군/구)',
                hintText: '예: 서울시 강남구',
                validator: (value) {
                  if (value == null || value.isEmpty) return '사는 곳을 입력해주세요.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // 성별 선택
              Text('성별', style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('남성', style: GoogleFonts.gaegu()),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('여성', style: GoogleFonts.gaegu()),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // 회원가입 버튼
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '가입하기',
                  style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 텍스트 필드 위젯
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

  // 버튼이 있는 텍스트 필드 위젯
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
              // 아이디나 닉네임이 변경되면 중복확인 상태를 리셋
              if (labelText == '아이디') {
                setState(() => _idChecked = false);
              } else if (labelText == '닉네임') {
                setState(() => _nicknameChecked = false);
              }
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
