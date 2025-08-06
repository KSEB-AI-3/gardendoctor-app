import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/diary_response_model.dart';

part 'diary_api_service.g.dart';

@RestApi()
abstract class DiaryApiService {
  factory DiaryApiService(Dio dio, {String baseUrl}) = _DiaryApiService;

  // 1. 내 모든 일지 조회
  @GET('/api/diaries/my-diaries')
  Future<List<DiaryResponse>> getAllMyDiaries();

  // 2. 일지 상세 조회
  @GET('/api/diaries/{diaryId}')
  Future<DiaryResponse> getDiary(@Path("diaryId") int diaryId);

  // 3. 여러 식물(userPlantIds)로 일지 필터 (콤마 구분, ex: 1,2,3)
  @GET('/api/diaries/my-diaries/by-user-plants')
  Future<List<DiaryResponse>> getDiariesByUserPlants(@Query('userPlantIds') List<int> userPlantIds);

  // 4. 특정 식물(userPlantId)로 일지 필터
  @GET('/api/diaries/my-diaries/by-user-plant/{userPlantId}')
  Future<List<DiaryResponse>> getDiariesByUserPlant(@Path("userPlantId") int userPlantId);

  // 5. 일지 삭제
  @DELETE("/api/diaries/{diaryId}")
  Future<void> deleteDiary(@Path("diaryId") int diaryId);
}
