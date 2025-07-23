import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import 'note_screen.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Note>> _events = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 필터링을 위한 상태 변수 (여러 개 선택 가능하도록 List로 변경)
  List<String> _selectedPlantFilters = [];

  // 등록된 식물 목록 (임시 데이터 - 더 많은 식물로 확장)
  final List<String> _myRegisteredPlants = [
    '내 첫 토마토', '베란다 참외', '옥상 포도', '미니 단호박',
    '상추', '깻잎', '바질', '로즈마리', '민트', '라벤더',
    '장미', '선인장', '다육이', '고무나무', '몬스테라',
    '스킨답서스', '산세베리아', '아이비', '틸란드시아'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 필터링된 이벤트 목록을 가져오는 함수
  List<Note> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    final allNotes = _events[normalizedDay] ?? [];
    if (_selectedPlantFilters.isEmpty) {
      return allNotes;
    }
    return allNotes.where((note) => _selectedPlantFilters.contains(note.registeredPlantNickname)).toList();
  }

  void _addOrUpdateNote(Note newNote) {
    DateTime normalizedDay = DateTime(newNote.date.year, newNote.date.month, newNote.date.day);
    setState(() {
      if (_events[normalizedDay] != null) {
        _events[normalizedDay]!.add(newNote);
      } else {
        _events[normalizedDay] = [newNote];
      }
    });
  }

  // 식물 필터 선택 바텀시트 표시
  void _showPlantFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlantFilterBottomSheet(
        allPlants: _myRegisteredPlants,
        initiallySelectedPlants: _selectedPlantFilters,
        onApplyFilter: (selected) {
          setState(() {
            _selectedPlantFilters = selected;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildCalendarCard(),
            _buildDateHeader(),
            Expanded(
              child: _buildEventList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Text(
        '성장 일지',
        style: GoogleFonts.gaegu(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black87,
        ),
      ),
      actions: [
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _selectedPlantFilters.isNotEmpty ? const Color(0xFF2ECC71) : Colors.grey[600],
            ),
            onPressed: _showPlantFilterBottomSheet,
          ),
          if (_selectedPlantFilters.isNotEmpty)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${_selectedPlantFilters.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TableCalendar<Note>(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _animationController.reset();
          _animationController.forward();
        },
        eventLoader: _getEventsForDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF2ECC71),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.orangeAccent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.gaegu(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.gaegu(color: Colors.grey[600]),
          weekendStyle: GoogleFonts.gaegu(color: const Color(0xFF2ECC71)),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('M월 d일 EEEE', 'ko_KR').format(_selectedDay!),
                style: GoogleFonts.gaegu(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                '${_getEventsForDay(_selectedDay!).length}개의 기록',
                style: GoogleFonts.gaegu(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (_selectedPlantFilters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: _selectedPlantFilters.map((plant) {
                  return Chip(
                    label: Text(plant, style: GoogleFonts.gaegu(fontSize: 12, color: const Color(0xFF27AE60))),
                    backgroundColor: const Color(0xFF2ECC71).withOpacity(0.1),
                    onDeleted: () {
                      setState(() {
                        _selectedPlantFilters.remove(plant);
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: events.isEmpty ? _buildEmptyState() : _buildEventListView(events),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _selectedPlantFilters.isEmpty ? '이 날짜에 작성된 일지가 없어요' : '선택된 식물의 일지가 없어요',
            style: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventListView(List<Note> events) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final note = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              // TODO: 상세 보기 화면으로 이동
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (note.registeredPlantNickname != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '🌱 ${note.registeredPlantNickname}',
                            style: GoogleFonts.gaegu(
                              fontSize: 13,
                              color: const Color(0xFF27AE60),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          if (note.watered) _buildCareIcon(Icons.water_drop_rounded, const Color(0xFF3498DB)),
                          if (note.fertilized) _buildCareIcon(Icons.science_rounded, const Color(0xFFE67E22)),
                          if (note.pruned) _buildCareIcon(Icons.grass_rounded, const Color(0xFF9B59B6)),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(note.image!.path),
                            width: 70, height: 70, fit: BoxFit.cover,
                          ),
                        ),
                      if (note.image != null) const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.gaegu(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCareIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push<Note>(
          context,
          MaterialPageRoute(
            builder: (_) => NoteScreen(selectedDate: _selectedDay!),
          ),
        );
        if (result != null) {
          _addOrUpdateNote(result);
        }
      },
      backgroundColor: const Color(0xFF2ECC71),
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.edit),
    );
  }
}

// 식물 필터 선택을 위한 바텀시트 위젯
class PlantFilterBottomSheet extends StatefulWidget {
  final List<String> allPlants;
  final List<String> initiallySelectedPlants;
  final Function(List<String>) onApplyFilter;

  const PlantFilterBottomSheet({
    super.key,
    required this.allPlants,
    required this.initiallySelectedPlants,
    required this.onApplyFilter,
  });

  @override
  State<PlantFilterBottomSheet> createState() => _PlantFilterBottomSheetState();
}

class _PlantFilterBottomSheetState extends State<PlantFilterBottomSheet> {
  late TextEditingController _searchController;
  late List<String> _filteredPlants;
  late List<String> _tempSelectedPlants;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredPlants = widget.allPlants;
    _tempSelectedPlants = List.from(widget.initiallySelectedPlants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPlants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlants = widget.allPlants;
      } else {
        _filteredPlants = widget.allPlants
            .where((plant) => plant.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('식물별로 모아보기', style: GoogleFonts.gaegu(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => setState(() => _tempSelectedPlants.clear()),
                  child: Text('전체 해제', style: GoogleFonts.gaegu(fontSize: 14, color: Colors.redAccent)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPlants,
              decoration: InputDecoration(
                hintText: '식물 이름을 검색해보세요',
                hintStyle: GoogleFonts.gaegu(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredPlants.isEmpty
                ? Center(
              child: Text('검색 결과가 없습니다', style: GoogleFonts.gaegu(fontSize: 16, color: Colors.grey[600])),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredPlants.length,
              itemBuilder: (context, index) {
                final plant = _filteredPlants[index];
                final isSelected = _tempSelectedPlants.contains(plant);

                return CheckboxListTile(
                  title: Text(plant, style: GoogleFonts.gaegu(fontSize: 16)),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _tempSelectedPlants.add(plant);
                      } else {
                        _tempSelectedPlants.remove(plant);
                      }
                    });
                  },
                  activeColor: const Color(0xFF2ECC71),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilter(_tempSelectedPlants);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('필터 적용하기', style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
