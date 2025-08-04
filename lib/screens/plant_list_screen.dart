import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_plant_model.dart';
import 'register_plant_screen.dart';
import 'plant_detail_screen.dart'; // 상세화면 import!

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  List<UserPlantResponse> _plants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  Future<void> _fetchPlants() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final dio = Dio(BaseOptions(
      baseUrl: "http://172.16.231.57:8080",
      headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
    ));

    try {
      final response = await dio.get('/api/user-plants');

      // [1] 서버 원본 응답 구조를 print로 출력!
      print('[DEBUG] 서버 응답: ${response.data}');

      // [2] 만약 서버 응답이 List<Map>형태가 아닐 수도 있으니, 타입 확인
      if (response.data is List) {
        final List<dynamic> data = response.data;
        _plants = data.map((e) {
          final plant = UserPlantResponse.fromJson(e);
          // [3] 각각의 userPlantId도 print
          print('[DEBUG] 생성된 UserPlantResponse userPlantId: ${plant.userPlantId}, json: $e');
          return plant;
        }).toList();
      } else {
        // [4] 혹시 서버에서 {"data": [...]} 형태로 주는 경우 대응
        if (response.data is Map && response.data['data'] is List) {
          final List<dynamic> data = response.data['data'];
          _plants = data.map((e) => UserPlantResponse.fromJson(e)).toList();
        } else {
          print('[ERROR] 서버에서 알 수 없는 형식의 데이터를 반환했습니다.');
          _plants = [];
        }
      }

      setState(() {
        _loading = false;
      });
    } catch (e, stack) {
      print("[DEBUG] 에러: $e");
      print(stack);
      setState(() => _loading = false);
    }
  }

  void _goToRegisterPlant() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPlantScreen()),
    );
    _fetchPlants(); // 등록 완료 후 돌아오면 목록 새로고침
  }

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
            onPressed: _goToRegisterPlant,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
          ? Center(
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
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _plants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, idx) {
          final plant = _plants[idx];

          // [5] 각 아이템 터치 시 userPlantId debug print
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: plant.userPlantImageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  plant.userPlantImageUrl!,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.eco, color: Color(0xFF2ECC71), size: 36),
                ),
              )
                  : const Icon(Icons.eco, size: 36, color: Color(0xFF2ECC71)),
              title: Text(
                plant.plantNickname ?? '',
                style: GoogleFonts.gaegu(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${plant.plantName ?? ''}  |  ${plant.plantingPlace ?? ''}',
                style: GoogleFonts.gaegu(fontSize: 16),
              ),
              onTap: () {
                print('[DEBUG] onTap: plant.userPlantId = ${plant.userPlantId}');
                if (plant.userPlantId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlantDetailScreen(userPlantId: plant.userPlantId!),
                    ),
                  );
                } else {
                  // [6] userPlantId가 null일 때 경고
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("userPlantId가 null입니다. DB/백엔드 응답을 확인하세요.", style: GoogleFonts.gaegu())),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
