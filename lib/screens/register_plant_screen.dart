import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../services/farm_api_service.dart';
import '../services/dio_interceptor.dart'; // ⭐️ Interceptor import!
import '../models/farm_model.dart';
import 'confirmation_screen.dart';

class PlantSample {
  final String name;
  final String imagePath;
  PlantSample({required this.name, required this.imagePath});
}

class RegisterPlantScreen extends StatefulWidget {
  const RegisterPlantScreen({super.key});

  @override
  State<RegisterPlantScreen> createState() => _RegisterPlantScreenState();
}

class _RegisterPlantScreenState extends State<RegisterPlantScreen> {
  final TextEditingController _customPlantController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedPlantName;
  String? _customPlantName;
  XFile? _imageFile;

  late final FarmApiService farmApiService;

  final List<PlantSample> _plantSamples = [
    PlantSample(name: '상추', imagePath: 'assets/images/상추.png'),
    PlantSample(name: '토마토', imagePath: 'assets/images/토마토.png'),
    PlantSample(name: '고추', imagePath: 'assets/images/고추.png'),
    PlantSample(name: '포도', imagePath: 'assets/images/포도.png'),
    PlantSample(name: '오이', imagePath: 'assets/images/오이.png'),
    PlantSample(name: '가지', imagePath: 'assets/images/가지.png'),
    PlantSample(name: '단호박', imagePath: 'assets/images/단호박.png'),
    PlantSample(name: '애호박', imagePath: 'assets/images/애호박.png'),
    PlantSample(name: '쥬키니 호박', imagePath: 'assets/images/쥬키니호박.png'),
    PlantSample(name: '딸기', imagePath: 'assets/images/딸기.png'),
    PlantSample(name: '수박', imagePath: 'assets/images/수박.png'),
    PlantSample(name: '참외', imagePath: 'assets/images/참외.png'),
  ];

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(
      baseUrl: 'http://172.16.231.57:8080',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ));
    dio.interceptors.add(DioInterceptor()); // ⭐️ 반드시 Interceptor 추가!
    farmApiService = FarmApiService(dio);
  }
  @override
  void dispose() {
    _customPlantController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _navigateToConfirmation() {
    final plantType = _selectedPlantName ?? _customPlantName;
    if (plantType == null || plantType.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('식물 종류를 선택해주세요!', style: GoogleFonts.gaegu()))
      );
      return;
    }
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('별명을 입력해주세요!', style: GoogleFonts.gaegu()))
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('키우는 장소를 입력해주세요!', style: GoogleFonts.gaegu()))
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          plantType: plantType,
          nickname: _nicknameController.text,
          location: _locationController.text,
          notes: _notesController.text,
          imageFile: _imageFile,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  void _showCustomPlantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('직접 입력하기', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        content: TextFormField(
          controller: _customPlantController,
          decoration: InputDecoration(
            hintText: '예: 래디쉬, 바질 등',
            hintStyle: GoogleFonts.gaegu(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          style: GoogleFonts.gaegu(fontSize: 16),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소', style: GoogleFonts.gaegu())),
          TextButton(
            onPressed: () {
              if (_customPlantController.text.isNotEmpty) {
                setState(() {
                  _customPlantName = _customPlantController.text;
                  _selectedPlantName = null;
                });
                Navigator.pop(context);
              }
            },
            child: Text('확인', style: GoogleFonts.gaegu(color: const Color(0xFF2ECC71))),
          ),
        ],
      ),
    );
  }

  // 텃밭 검색 모달 띄우기
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 식물 등록', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '어떤 식물인가요?',
              subtitle: '키우실 식물 종류를 선택하거나 직접 입력해주세요.',
              content: _buildPlantSelectionContent(),
            ),
            _buildSection(
              title: '별명이 뭔가요?',
              subtitle: '식물에게 특별한 이름을 지어주세요.',
              content: _buildNicknameInput(),
            ),
            _buildSection(
              title: '어디서 키우나요?',
              subtitle: '식물을 키우는 장소를 알려주세요.',
              content: _buildLocationInput(),
            ),
            _buildSection(
              title: '메모(선택)',
              subtitle: '간단한 메모나 기록을 남겨보세요.',
              content: _buildNotesInput(),
            ),
            _buildSection(
              title: '사진을 등록해주세요 (선택)',
              subtitle: '식물의 대표 사진을 선택해주세요.',
              content: _buildPhotoInput(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToConfirmation,
                icon: const Icon(Icons.check_circle_outline),
                label: Text('등록 정보 확인하기', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String subtitle, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.gaegu(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(subtitle, style: GoogleFonts.gaegu(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 24),
        content,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPlantSelectionContent() {
    return Column(
      children: [
        if (_customPlantName != null)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2ECC71)),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: Color(0xFF2ECC71)),
                const SizedBox(width: 12),
                Text(_customPlantName!, style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _customPlantName = null),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: _plantSamples.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: _showCustomPlantDialog,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, color: Colors.grey, size: 24),
                      const SizedBox(height: 8),
                      Text('직접 입력', style: GoogleFonts.gaegu(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                    ],
                  ),
                ),
              );
            }
            final plant = _plantSamples[index - 1];
            final isSelected = _selectedPlantName == plant.name;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedPlantName = isSelected ? null : plant.name;
                _customPlantName = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? const Color(0xFF2ECC71) : Colors.grey.shade300, width: isSelected ? 3 : 1.5),
                  boxShadow: [BoxShadow(color: isSelected ? const Color(0xFF2ECC71).withOpacity(0.2) : Colors.grey.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(plant.imagePath, width: 45, height: 45, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.eco, color: Colors.grey, size: 24)),
                    const SizedBox(height: 8),
                    Text(plant.name, style: GoogleFonts.gaegu(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF2ECC71) : Colors.black87)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNicknameInput() {
    return TextFormField(
      controller: _nicknameController,
      decoration: InputDecoration(
        hintText: '예: 토순이, 우리집 상추 등',
        hintStyle: GoogleFonts.gaegu(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: GoogleFonts.gaegu(fontSize: 18),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildLocationInput() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: '예: 베란다, 창가, 옥상 등',
                  hintStyle: GoogleFonts.gaegu(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: GoogleFonts.gaegu(fontSize: 18),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            // 텃밭 검색 버튼
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _showFarmSearchModal,
                icon: const Icon(Icons.search, color: Colors.white, size: 24),
                tooltip: '텃밭 검색',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 텃밭 검색 안내 텍스트
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFF2ECC71), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '텃밭에서 키우시나요? 오른쪽 검색 버튼을 눌러 텃밭을 찾아보세요!',
                  style: GoogleFonts.gaegu(fontSize: 14, color: const Color(0xFF2ECC71)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: '메모, 기록 등을 입력하세요 (선택)',
        hintStyle: GoogleFonts.gaegu(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: GoogleFonts.gaegu(fontSize: 18),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildPhotoInput() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          image: _imageFile != null ? DecorationImage(image: FileImage(File(_imageFile!.path)), fit: BoxFit.cover) : null,
        ),
        child: _imageFile == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('사진을 선택해주세요', style: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey[600])),
          ],
        )
            : null,
      ),
    );
  }
}

// 텃밭 검색 모달
class FarmSearchModal extends StatefulWidget {
  final FarmApiService farmApiService;
  final Function(Farm) onFarmSelected;

  const FarmSearchModal({
    super.key,
    required this.farmApiService,
    required this.onFarmSelected,
  });

  @override
  State<FarmSearchModal> createState() => _FarmSearchModalState();
}

class _FarmSearchModalState extends State<FarmSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Farm> _searchResults = [];
  bool _isSearching = false;
  String _searchKeyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFarms(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchKeyword = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchKeyword = keyword;
    });

    try {
      final results = await widget.farmApiService.searchFarms(keyword);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('검색 중 오류가 발생했습니다: ${e.toString()}', style: GoogleFonts.gaegu()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 모달 헤더
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.agriculture, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '텃밭 검색',
                        style: GoogleFonts.gaegu(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 검색창
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '텃밭명이나 주소를 입력하세요',
                hintStyle: GoogleFonts.gaegu(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2ECC71)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: GoogleFonts.gaegu(fontSize: 16),
              onChanged: (value) {
                // 디바운싱을 위한 타이머 구현
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _searchFarms(value);
                  }
                });
              },
              onFieldSubmitted: _searchFarms,
            ),
          ),
          // 검색 결과
          Expanded(
            child: _isSearching
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2ECC71)),
                  SizedBox(height: 16),
                  Text('텃밭을 검색하고 있습니다...'),
                ],
              ),
            )
                : _searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchKeyword.isEmpty ? Icons.search : Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchKeyword.isEmpty
                        ? '텃밭명이나 주소를 검색해보세요'
                        : '검색 결과가 없습니다',
                    style: GoogleFonts.gaegu(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_searchKeyword.isNotEmpty)
                    Text(
                      '다른 키워드로 검색해보세요',
                      style: GoogleFonts.gaegu(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final farm = _searchResults[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: Color(0xFF2ECC71),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      farm.farmName ?? '텃밭명 없음',
                      style: GoogleFonts.gaegu(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (farm.operator != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '운영: ${farm.operator}',
                            style: GoogleFonts.gaegu(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          farm.roadNameAddress ?? farm.lotNumberAddress ?? '주소 정보 없음',
                          style: GoogleFonts.gaegu(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => widget.onFarmSelected(farm),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}