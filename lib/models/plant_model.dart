import 'package:json_annotation/json_annotation.dart';

part 'plant_model.g.dart';

@JsonSerializable()
class Plant {
  final int plantId;
  final String? plantName;         // 이름 변경!
  final String? plantEnglishName;  // 이름 변경!
  final String? species;
  final String? season;
  final String? imageUrl; // 이건 파일명이나 URL로 내려오면 그대로

  Plant({
    required this.plantId,
    this.plantName,
    this.plantEnglishName,
    this.species,
    this.season,
    this.imageUrl,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
  Map<String, dynamic> toJson() => _$PlantToJson(this);
}
