import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user_plant_model.dart';

part 'user_plant_api_service.g.dart';

@RestApi()
abstract class UserPlantApiService {
  factory UserPlantApiService(Dio dio, {String baseUrl}) = _UserPlantApiService;

  @PUT('/api/user-plants/{userPlantId}')
  @MultiPart()
  Future<UserPlantResponse> updateUserPlant(
      @Path("userPlantId") int userPlantId,
      @Part(name: 'data') String userPlantJson,
      @Part(name: 'file') MultipartFile? imageFile,
      );

  @DELETE('/api/user-plants/{userPlantId}')
  Future<void> deleteUserPlant(
      @Path("userPlantId") int userPlantId,
      );
}
