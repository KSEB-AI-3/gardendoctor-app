import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "마이페이지",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2ECC71),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF2ECC71)),
                title: const Text("내 정보 보기"),
                onTap: () {
                  // 내 정보 상세보기
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF2ECC71)),
                title: const Text("설정"),
                onTap: () {
                  // 설정 화면
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF2ECC71)),
                title: const Text("로그아웃"),
                onTap: () {
                  // 로그아웃 후 로그인 화면으로 이동
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
