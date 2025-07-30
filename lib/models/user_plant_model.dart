import 'package:json_annotation/json_annotation.dart';

part 'user_plant_model.g.dart';

@JsonSerializable()
class UserPlantResponse {
  final int userPlantId;
  final int userId;
  final String? plantName;
  final String? nickname;
  final String? plantingPlace;
  final String? plantedDate; // DateTime으로 파싱하려면 별도 로직 필요
  final String? notes;
  final String? userPlantImageUrl;

  final String? plantEnglishName;
  final String? species;
  final String? season;
  final String? plantImageUrl;

  UserPlantResponse({
    required this.userPlantId,
    required this.userId,
    this.plantName,
    this.nickname,
    this.plantingPlace,
    this.plantedDate,
    this.notes,
    this.userPlantImageUrl,
    this.plantEnglishName,
    this.species,
    this.season,
    this.plantImageUrl,
  });

  factory UserPlantResponse.fromJson(Map<String, dynamic> json) => _$UserPlantResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserPlantResponseToJson(this);
}