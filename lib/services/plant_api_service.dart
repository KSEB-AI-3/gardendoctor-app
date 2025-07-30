import 'dart:io'; // 1. dart:io import 추가
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/plant_model.dart';
import '../models/user_plant_model.dart';

part 'plant_api_service.g.dart'; // 2. 파일명과 일치시키기

@RestApi(baseUrl: "http://172.16.183.114:8080/api")
abstract class PlantApiService { // 3. 클래스 이름 변경
  factory PlantApiService(Dio dio, {String baseUrl}) = _PlantApiService;

  @GET("/plants")
  Future<List<Plant>> getAllPlants();

  @POST("/user-plants")
  @MultiPart()
  Future<UserPlantResponse> createUserPlant(
      @Part(name: "userId") int userId,
      @Part(name: "plantName") String plantName,
      @Part(name: "nickname") String nickname,
      @Part(name: "gardenUniqueId") int gardenUniqueId,
      @Part(name: "plantingPlace") String plantingPlace,
      @Part(name: "plantedDate") String plantedDate,
      @Part(name: "imageFile") File imageFile, // 4. MultipartFile -> File 로 변경
      );
}