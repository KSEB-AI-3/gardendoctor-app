import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// 샘플 식물 데이터를 위한 클래스
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
  final ImagePicker _picker = ImagePicker();

  String? _selectedPlantName;
  String? _customPlantName;
  XFile? _imageFile;

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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.gaegu(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: GoogleFonts.gaegu()),
          ),
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  @override
  void dispose() {
    _customPlantController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSection(
              title: '어떤 식물인가요?',
              subtitle: '키우실 식물 종류를 선택하거나 직접 입력해주세요.',
              content: _buildPlantSelectionContent(),
            ),
            _buildAnimatedSection(
              isVisible: _selectedPlantName != null || (_customPlantName != null && _customPlantName!.isNotEmpty),
              content: _buildSection(
                title: '별명이 뭔가요?',
                subtitle: '식물에게 특별한 이름을 지어주세요.',
                content: _buildNicknameInput(),
              ),
            ),
            _buildAnimatedSection(
              isVisible: _nicknameController.text.isNotEmpty,
              content: _buildSection(
                title: '어디서 키우나요?',
                subtitle: '식물을 키우는 장소를 알려주세요.',
                content: _buildLocationInput(),
              ),
            ),
            _buildAnimatedSection(
              isVisible: _locationController.text.isNotEmpty,
              content: _buildSection(
                title: '사진을 등록해주세요',
                subtitle: '식물의 대표 사진을 선택해주세요.',
                content: _buildPhotoInput(),
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

  Widget _buildAnimatedSection({required bool isVisible, required Widget content}) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: isVisible ? content : const SizedBox.shrink(),
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
            crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8,
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
                    border: Border.all(color: Colors.grey.shade300, width: 1.5, style: BorderStyle.solid),
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
                if (isSelected) {
                  _selectedPlantName = null;
                } else {
                  _selectedPlantName = plant.name;
                  _customPlantName = null;
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? const Color(0xFF2ECC71) : Colors.grey.shade300, width: isSelected ? 3 : 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? const Color(0xFF2ECC71).withOpacity(0.2) : Colors.grey.withOpacity(0.05),
                      blurRadius: 8, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        plant.imagePath, width: 45, height: 45, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 45, height: 45,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.eco, color: Colors.grey, size: 24),
                        ),
                      ),
                    ),
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
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        hintText: '예: 베란다, 텃밭, 창가 등',
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

  Widget _buildPhotoInput() {
    return Column(
      children: [
        GestureDetector(
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
        ),
        const SizedBox(height: 24),
        if (_imageFile != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 👇 확인 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfirmationScreen(
                      plantType: _selectedPlantName ?? _customPlantName ?? '미지정',
                      nickname: _nicknameController.text,
                      location: _locationController.text,
                      imageFile: _imageFile!,
                    ),
                  ),
                );
              },
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
    );
  }
}

// 👇 최종 확인을 위한 별도의 페이지 위젯
class ConfirmationScreen extends StatelessWidget {
  final String plantType;
  final String nickname;
  final String location;
  final XFile imageFile;

  const ConfirmationScreen({
    super.key,
    required this.plantType,
    required this.nickname,
    required this.location,
    required this.imageFile,
  });

  void _completeRegistration(BuildContext context) {
    // TODO: 등록 로직 구현
    print('식물 종류: $plantType');
    print('별명: $nickname');
    print('장소: $location');
    print('사진 경로: ${imageFile.path}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$nickname" 등록 완료!', style: GoogleFonts.gaegu())),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('등록할 정보를 확인해주세요', style: GoogleFonts.gaegu(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(File(imageFile.path), height: 250, fit: BoxFit.cover),
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
                  _buildInfoRow(Icons.eco, '종류', plantType),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.pets, '별명', nickname),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.location_on, '장소', location),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _completeRegistration(context),
                icon: const Icon(Icons.check_circle),
                label: Text('최종 등록하기', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Text(value, style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}