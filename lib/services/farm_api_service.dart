// lib/services/farm_api_service.dart
import 'package:dio/dio.dart';
import '../models/farm_model.dart';

class FarmApiService {
  final Dio dio;

  FarmApiService(this.dio);

  /// 전체 텃밭 목록 조회
  Future<List<Farm>> getAllFarms() async {
    final res = await dio.get('/api/farms');
    // 결과값이 List가 아닐 때를 대비한 null check(실패 방지)
    final List farms = res.data as List? ?? [];
    return farms.map((json) => Farm.fromJson(json)).toList();
  }

  /// 내 주변 텃밭 (위치기반)
  Future<List<Farm>> getNearbyFarms({
    required double latitude,
    required double longitude,
    double radius = 20,
  }) async {
    final res = await dio.get(
      '/api/farms/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );
    final List farms = res.data as List? ?? [];
    return farms.map((json) => Farm.fromJson(json)).toList();
  }

  /// 텃밭 검색 (name/address)
  Future<List<Farm>> searchFarms(String searchType, String keyword) async {
    final res = await dio.get(
      '/api/farms/search',
      queryParameters: {
        'searchType': searchType,
        'keyword': keyword,
      },
    );
    final List farms = res.data as List? ?? [];
    return farms.map((json) => Farm.fromJson(json)).toList();
  }

  /// 단일 텃밭 상세 조회
  Future<Farm> getFarmDetail(int farmId) async {
    final res = await dio.get('/api/farms/$farmId');
    return Farm.fromJson(res.data);
  }
}
