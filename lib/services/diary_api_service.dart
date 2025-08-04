import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/diary_response_model.dart';

part 'diary_api_service.g.dart';

@RestApi()
abstract class DiaryApiService {
  factory DiaryApiService(Dio dio, {String baseUrl}) = _DiaryApiService;

  // 내 모든 일지 조회
  @GET('/api/diaries/my-diaries')
  Future<List<DiaryResponse>> getAllMyDiaries();

  // 일지 삭제
  @DELETE("/api/diaries/{diaryId}")
  Future<void> deleteDiary(
      @Path("diaryId") int diaryId,
      );
}
