import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

import '../../models/user_plant_request_model.dart';

class ConfirmationScreen extends StatefulWidget {
  final String plantType;
  final String nickname;
  final String location;
  final String notes;     // 메모 추가!
  final XFile? imageFile;

  const ConfirmationScreen({
    super.key,
    required this.plantType,
    required this.nickname,
    required this.location,
    required this.notes,    // 메모 추가!
    this.imageFile,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _isLoading = false;

  Future<void> _completeRegistration() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          message: '인증 정보가 없습니다. 다시 로그인해주세요.',
        );
      }

      // 1. Dio 인스턴스 + 헤더 세팅
      final dio = Dio(BaseOptions(
        baseUrl: "http://172.16.231.57:8080",
        headers: {"Authorization": "Bearer $accessToken"},
      ));

      // 2. DTO -> JSON String
      final requestDto = UserPlantRequest(
        plantName: widget.plantType,
        plantNickname: widget.nickname,
        plantingPlace: widget.location,
        gardenUniqueId: 0,
        plantedDate: DateTime.now().toIso8601String(),
        notes: widget.notes, // 메모 전달
      );
      final String dataJson = jsonEncode(requestDto.toJson());

      // 3. FormData 생성
      final formData = FormData();

      // JSON part 추가 (Content-Type 명확히)
      formData.files.add(
        MapEntry(
          "data",
          MultipartFile.fromString(
            dataJson,
            contentType: MediaType("application", "json"),
            filename: "data.json",
          ),
        ),
      );

      // 이미지 파일 part 추가 (있으면)
      if (widget.imageFile != null) {
        final file = File(widget.imageFile!.path);
        formData.files.add(
          MapEntry(
            "file",
            await MultipartFile.fromFile(
              file.path,
              filename: "plant.jpg",
              contentType: MediaType("image", "jpeg"),
            ),
          ),
        );
      }

      // 4. POST 요청 (직접 dio)
      final response = await dio.post("/api/user-plants", data: formData);

      // 5. 성공
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${widget.nickname}" 등록이 완료되었어요!', style: GoogleFonts.gaegu()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        throw Exception("등록 실패: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (mounted) {
        final errorMessage = e.response?.data['message'] ?? e.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('등록에 실패했어요: $errorMessage', style: GoogleFonts.gaegu()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('정보 확인', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('등록할 정보를 확인해주세요', style: GoogleFonts.gaegu(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.imageFile != null
                    ? Image.file(File(widget.imageFile!.path), height: 250, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('이미지 없음', style: GoogleFonts.gaegu(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.eco, '종류', widget.plantType),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.pets, '별명', widget.nickname),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.location_on, '장소', widget.location),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.sticky_note_2, '메모', widget.notes.isNotEmpty ? widget.notes : '없음'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _completeRegistration,
                icon: _isLoading
                    ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : const Icon(Icons.check_circle),
                label: Text(_isLoading ? '등록 중...' : '최종 등록하기', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Text('$label:', style: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey[700])),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
