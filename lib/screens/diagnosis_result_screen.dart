// 파일 위치: screens/diagnosis_result_screen.dart (덮어쓰기)
// 설명: UI를 전면적으로 개선하고, 'AI 챗봇과 상담하기' 기능을 추가한 최종 코드입니다.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot_screen.dart'; // 챗봇 화면 import

class DiagnosisResultScreen extends StatelessWidget {
  final XFile image;

  const DiagnosisResultScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // 배경색 변경
      appBar: AppBar(
        title: Text('AI 진단 결과', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 진단 이미지 섹션
            Text("진단 이미지", style: GoogleFonts.gaegu(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(image.path),
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),

            // 2. 진단 결과 카드
            _buildResultCard(
              icon: Icons.biotech_outlined,
              iconColor: Colors.orange.shade700,
              title: '진단 요약',
              content: 'AI가 이미지를 분석한 결과, 잎마름병 초기 증상으로 의심됩니다. 잎 끝이 노랗게 변하고 있으며, 수분 부족 또는 영양 불균형이 원인일 수 있습니다.',
            ),
            const SizedBox(height: 20),

            // 3. 예상 병명 및 대처 방안 카드
            _buildResultCard(
              icon: Icons.medical_services_outlined,
              iconColor: Colors.red.shade600,
              title: '예상 병명: 잎마름병 (초기)',
              content: '1. 물주기: 흙이 너무 마르지 않도록 주기적으로 확인하고, 물을 충분히 주세요.\n2. 영양 공급: 질소 기반의 비료를 소량 사용하여 상태를 지켜보세요.\n3. 통풍: 식물 주변의 통풍이 잘 되도록 환경을 개선해주세요.',
            ),
            const SizedBox(height: 32),

            // 4. 챗봇 상담 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                  );
                },
                icon: const Icon(Icons.support_agent_rounded),
                label: Text('AI 챗봇과 상담하기', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF2ECC71).withOpacity(0.4),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 결과 카드를 만드는 위젯
  Widget _buildResultCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.gaegu(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Text(
            content,
            style: GoogleFonts.gaegu(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.7, // 줄 간격 조절
            ),
          ),
        ],
      ),
    );
  }
}
