// lib/services/diary_api_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/diary_response_model.dart';

part 'diary_api_service.g.dart';

@RestApi()
abstract class DiaryApiService {
  factory DiaryApiService(Dio dio, {String baseUrl}) = _DiaryApiService;

  @POST("/api/diaries")
  @MultiPart()
  Future<DiaryResponse> createDiaryWithFile(
      @Part(name: "request") String diaryRequest, // 👈 타입을 String으로 변경
      @Part(name: "file") File imageFile,
      );

  @POST("/api/diaries")
  @MultiPart()
  Future<DiaryResponse> createDiary(
      @Part(name: "request") String diaryRequest, // 👈 타입을 String으로 변경
      );

  @GET('/api/diaries/my-diaries')
  Future<List<DiaryResponse>> getAllMyDiaries();
}