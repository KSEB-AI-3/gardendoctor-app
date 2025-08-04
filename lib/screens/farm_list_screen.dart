import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/farm_model.dart';
import '../services/farm_api_service.dart';

class FarmListScreen extends StatefulWidget {
  const FarmListScreen({super.key});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  late final FarmApiService farmApiService;
  List<Farm> farmList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(
      baseUrl: 'http://172.16.231.57:8080',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ));
    farmApiService = FarmApiService(dio);
    fetchFarms();
  }

  Future<void> fetchFarms() async {
    try {
      final farms = await farmApiService.getAllFarms();
      setState(() {
        farmList = farms;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // 에러 핸들링 (SnackBar 등)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주말농장 목록')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: farmList.length,
        itemBuilder: (context, index) {
          final farm = farmList[index];
          return ListTile(
            title: Text(farm.farmName ?? '텃밭 이름 없음'), // name → farmName
            subtitle: Text(farm.roadNameAddress ?? '주소 없음'),
          );
        },
      ),
    );
  }
}
