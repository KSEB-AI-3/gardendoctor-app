import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_plant_screen.dart'; // 새로 만들 식물 등록 화면 import

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 식물 목록', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPlantScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grass, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '아직 등록된 식물이 없어요.\n오른쪽 위 + 버튼을 눌러 추가해보세요!',
              textAlign: TextAlign.center,
              style: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
