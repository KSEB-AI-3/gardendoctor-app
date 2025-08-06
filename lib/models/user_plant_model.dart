import 'package:json_annotation/json_annotation.dart';

part 'user_plant_model.g.dart';

@JsonSerializable()
class UserPlantResponse {
  final int? userPlantId;
  final String? plantName;
  final String? plantNickname;
  final String? plantingPlace;
  final String? plantedDate;
  final String? notes;
  final String? userPlantImageUrl;
  final String? plantEnglishName;
  final String? species;
  final String? season;
  final String? plantImageUrl;
  final int? gardenUniqueId;  // ✅ 추가

  UserPlantResponse({
    this.userPlantId,
    this.plantName,
    this.plantNickname,
    this.plantingPlace,
    this.plantedDate,
    this.notes,
    this.userPlantImageUrl,
    this.plantEnglishName,
    this.species,
    this.season,
    this.plantImageUrl,
    this.gardenUniqueId,   // ✅ 생성자에 추가
  });

  factory UserPlantResponse.fromJson(Map<String, dynamic> json) => _$UserPlantResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserPlantResponseToJson(this);
}
