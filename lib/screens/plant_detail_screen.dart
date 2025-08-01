import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_plant_model.dart';

class PlantDetailScreen extends StatefulWidget {
  final int userPlantId;

  const PlantDetailScreen({super.key, required this.userPlantId});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  UserPlantResponse? _plant;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final dio = Dio(BaseOptions(
      baseUrl: "http://172.16.183.114:8080",
      headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
    ));

    try {
      final response = await dio.get('/api/user-plants/${widget.userPlantId}');
      setState(() {
        _plant = UserPlantResponse.fromJson(response.data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "상세 정보를 불러오지 못했습니다.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식물 상세', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: GoogleFonts.gaegu(fontSize: 18, color: Colors.red)))
          : _plant == null
          ? const Center(child: Text('데이터가 없습니다.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _plant!.userPlantImageUrl != null
                    ? Image.network(
                  _plant!.userPlantImageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Icon(Icons.eco, size: 60, color: Colors.grey[400]),
                )
                    : Container(
                  width: double.infinity,
                  height: 220,
                  color: Colors.grey[200],
                  child: Icon(Icons.eco, size: 60, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _infoRow('별명', _plant!.plantNickname),
            _infoRow('종류', _plant!.plantName),
            _infoRow('영문명', _plant!.plantEnglishName),
            _infoRow('품종', _plant!.species),
            _infoRow('계절', _plant!.season),
            _infoRow('장소', _plant!.plantingPlace),
            _infoRow('심은 날짜', _plant!.plantedDate?.split('T').first),
            _infoRow('메모', _plant!.notes),
            if (_plant!.plantImageUrl != null) ...[
              const SizedBox(height: 24),
              Text('식물 정보 대표 사진', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(_plant!.plantImageUrl!, height: 120, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return value == null || value.isEmpty
        ? const SizedBox.shrink()
        : Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey[700])),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
