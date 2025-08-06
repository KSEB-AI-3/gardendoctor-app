import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // MediaType 사용
import '../../services/user_plant_api_service.dart';
import '../../models/user_plant_model.dart';
import 'register_plant_screen.dart'; // FarmSearchModal 재사용
import '../../services/farm_api_service.dart'; // ⭐ 추가
import '../../services/dio_interceptor.dart'; // ⭐ 추가

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
  bool _saving = false;

  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  File? _imageFile;

  late final FarmApiService farmApiService; // ⭐ 추가

  @override
  void initState() {
    super.initState();
    _fetchDetail();

    // ⭐ FarmSearchModal용 API 초기화
    final dio = Dio(BaseOptions(
      baseUrl: 'http://172.16.231.57:8080',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ));
    dio.interceptors.add(DioInterceptor());
    farmApiService = FarmApiService(dio);
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final dio = Dio(BaseOptions(
      baseUrl: "http://172.16.231.57:8080",
      headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
    ));

    try {
      final response = await dio.get('/api/user-plants/${widget.userPlantId}');
      setState(() {
        _plant = UserPlantResponse.fromJson(response.data);
        _loading = false;
        _nicknameController.text = _plant?.plantNickname ?? '';
        _locationController.text = _plant?.plantingPlace ?? '';
        _notesController.text = _plant?.notes ?? '';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "상세 정보를 불러오지 못했습니다.";
      });
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('삭제 확인', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        content: Text('정말로 이 식물을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.', style: GoogleFonts.gaegu()),
        actions: [
          TextButton(
            child: Text('취소', style: GoogleFonts.gaegu()),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('삭제', style: GoogleFonts.gaegu(color: Colors.redAccent)),
            onPressed: _deletePlant,
          ),
        ],
      ),
    );
  }

  void _deletePlant() async {
    Navigator.pop(context); // 다이얼로그 닫기
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final dio = Dio(BaseOptions(
      baseUrl: "http://172.16.231.57:8080",
      headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
    ));
    try {
      await dio.delete('/api/user-plants/${widget.userPlantId}');
      if (mounted) {
        Navigator.pop(context, true); // 목록 새로고침
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('식물 정보가 삭제되었습니다.', style: GoogleFonts.gaegu())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제에 실패했습니다.', style: GoogleFonts.gaegu()), backgroundColor: Colors.redAccent),
      );
    }
    setState(() => _saving = false);
  }

  // ⭐ 추가: 텃밭 검색 모달 열기
  void _showFarmSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FarmSearchModal(
        farmApiService: farmApiService,
        onFarmSelected: (farm) {
          setState(() {
            _locationController.text = '${farm.farmName ?? "-"} (${farm.roadNameAddress ?? farm.lotNumberAddress ?? ""})';
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('식물 정보 수정', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(labelText: '별명', labelStyle: GoogleFonts.gaegu()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: '장소',
                    labelStyle: GoogleFonts.gaegu(),
                    suffixIcon: IconButton( // ⭐ 검색 버튼 추가
                      icon: const Icon(Icons.search, color: Color(0xFF2ECC71)),
                      onPressed: _showFarmSearchModal,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: '메모', labelStyle: GoogleFonts.gaegu()),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setDialogState(() {
                        _imageFile = File(picked.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text('대표 이미지 선택', style: GoogleFonts.gaegu()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                  ),
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.file(_imageFile!, width: 80, height: 80),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: GoogleFonts.gaegu()),
            ),
            TextButton(
              onPressed: _saving ? null : _editPlant,
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('저장', style: GoogleFonts.gaegu(color: const Color(0xFF2ECC71))),
            ),
          ],
        ),
      ),
    );
  }

  void _editPlant() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final dio = Dio(BaseOptions(
      baseUrl: "http://172.16.231.57:8080",
      headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
    ));

    final userPlantJson = '''
  {
    "plantName": "${_plant?.plantName ?? ''}",
    "plantNickname": "${_nicknameController.text}",
    "plantingPlace": "${_locationController.text}",
    "notes": "${_notesController.text}",
    "gardenUniqueId": ${_plant?.gardenUniqueId ?? 1}
  }
  ''';

    try {
      final formData = FormData();

      formData.files.add(MapEntry(
        'data',
        MultipartFile.fromString(
          userPlantJson,
          contentType: MediaType('application', 'json'),
          filename: 'data.json',
        ),
      ));

      if (_imageFile != null) {
        final ext = _imageFile!.path.split('.').last.toLowerCase();
        String mimeType = 'jpeg';
        if (ext == 'png') mimeType = 'png';
        if (ext == 'jpg' || ext == 'jpeg') mimeType = 'jpeg';

        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            _imageFile!.path,
            filename: _imageFile!.path.split('/').last,
            contentType: MediaType('image', mimeType),
          ),
        ));
      }

      await dio.put(
        '/api/user-plants/${widget.userPlantId}',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        _fetchDetail();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('식물 정보가 수정되었습니다.', style: GoogleFonts.gaegu())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정에 실패했습니다. $e', style: GoogleFonts.gaegu()), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식물 상세', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: '수정',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
            tooltip: '삭제',
          ),
        ],
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
                  errorBuilder: (c, e, s) =>
                      Icon(Icons.eco, size: 60, color: Colors.grey[400]),
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
