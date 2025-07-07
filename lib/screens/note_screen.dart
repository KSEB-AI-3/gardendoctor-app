import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/note_model.dart';

// 등록된 내 식물 데이터를 위한 임시 클래스
class MyRegisteredPlant {
  final String nickname;
  final String imagePath;
  MyRegisteredPlant({required this.nickname, required this.imagePath});
}

class NoteScreen extends StatefulWidget {
  final DateTime selectedDate;
  const NoteScreen({super.key, required this.selectedDate});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<MyRegisteredPlant> _myRegisteredPlants = [
    MyRegisteredPlant(nickname: '내 첫 토마토', imagePath: 'assets/images/토마토.png'),
    MyRegisteredPlant(nickname: '베란다 참외', imagePath: 'assets/images/참외.png'),
    MyRegisteredPlant(nickname: '옥상 포도', imagePath: 'assets/images/포도.png'),
    MyRegisteredPlant(nickname: '미니 단호박', imagePath: 'assets/images/단호박.png'),
  ];
  String? _selectedMyPlant;

  XFile? _imageFile;
  bool _watered = false;
  bool _fertilized = false;
  bool _pruned = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('제목은 꼭 입력해주세요!', style: GoogleFonts.gaegu()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newNote = Note(
      title: _titleController.text.trim(),
      registeredPlantNickname: _selectedMyPlant,
      date: widget.selectedDate,
      image: _imageFile,
      watered: _watered,
      fertilized: _fertilized,
      pruned: _pruned,
      text: _notesController.text.trim(),
    );

    Navigator.pop(context, newNote);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy. MM. dd (E)', 'ko_KR').format(widget.selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        title: Text('오늘의 일지', style: GoogleFonts.gaegu(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF81C784),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: Text(
              '기록하기',
              style: GoogleFonts.gaegu(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateChip(formattedDate),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 24),
            _buildMyPlantSelection(),
            const SizedBox(height: 24),
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildCareSection(),
            const SizedBox(height: 24),
            _buildNoteField(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String formattedDate) {
    return Center(
      child: Text(
        formattedDate,
        style: GoogleFonts.gaegu(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        hintText: '✏️ 오늘의 일지 제목',
        hintStyle: GoogleFonts.gaegu(color: Colors.grey[500], fontSize: 24),
        border: InputBorder.none,
      ),
      style: GoogleFonts.gaegu(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF3E2723)),
    );
  }

  Widget _buildMyPlantSelection() {
    return DropdownButtonFormField<String>(
      value: _selectedMyPlant,
      hint: Text('어떤 식물의 기록인가요?', style: GoogleFonts.gaegu(color: Colors.grey[600])),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.filter_vintage_rounded, color: Color(0xFF2ECC71)),
        filled: true,
        fillColor: Colors.green.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      items: _myRegisteredPlants.map((plant) {
        return DropdownMenuItem(
          value: plant.nickname,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(plant.imagePath, width: 24, height: 24, fit: BoxFit.cover,
                  errorBuilder: (c,e,s) => const Icon(Icons.eco, size: 24),
                ),
              ),
              const SizedBox(width: 8),
              Text(plant.nickname, style: GoogleFonts.gaegu()),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMyPlant = value;
        });
      },
      style: GoogleFonts.gaegu(color: Colors.black87),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.brown.withOpacity(0.2)),
          image: _imageFile != null
              ? DecorationImage(
            image: FileImage(File(_imageFile!.path)),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: _imageFile == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.brown[300]),
              const SizedBox(height: 8),
              Text('사진 붙이기', style: GoogleFonts.gaegu(color: Colors.brown[400])),
            ],
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildCareSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCareItem(
          icon: Icons.water_drop_rounded,
          label: '물주기',
          isChecked: _watered,
          color: const Color(0xFF3498DB),
          onTap: () => setState(() => _watered = !_watered),
        ),
        _buildCareItem(
          icon: Icons.science_rounded,
          label: '영양제',
          isChecked: _fertilized,
          color: const Color(0xFFE67E22),
          onTap: () => setState(() => _fertilized = !_fertilized),
        ),
        _buildCareItem(
          icon: Icons.grass_rounded,
          label: '가지치기',
          isChecked: _pruned,
          color: const Color(0xFF9B59B6),
          onTap: () => setState(() => _pruned = !_pruned),
        ),
      ],
    );
  }

  Widget _buildCareItem({
    required IconData icon,
    required String label,
    required bool isChecked,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isChecked ? color : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: isChecked ? [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
              ] : [],
            ),
            child: Icon(icon, size: 28, color: isChecked ? Colors.white : Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.gaegu(fontWeight: FontWeight.bold, color: isChecked ? color : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: _notesController,
        maxLines: 10,
        decoration: InputDecoration(
          hintText: '오늘 식물은 어떤 모습이었나요?\n어떤 변화가 있었는지, 어떤 기분이 들었는지 자유롭게 기록해보세요...',
          hintStyle: GoogleFonts.gaegu(color: Colors.grey[400], height: 1.7),
          border: InputBorder.none,
        ),
        style: GoogleFonts.gaegu(fontSize: 16, height: 1.7, color: const Color(0xFF3E2723)),
      ),
    );
  }
}