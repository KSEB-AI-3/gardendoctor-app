import 'package:json_annotation/json_annotation.dart';

part 'plant_model.g.dart';

@JsonSerializable()
class Plant {
  final int plantId;
  final String? name;
  final String? englishName;
  final String? species;
  final String? season;
  final String? imageUrl;

  Plant({
    required this.plantId,
    this.name,
    this.englishName,
    this.species,
    this.season,
    this.imageUrl,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
  Map<String, dynamic> toJson() => _$PlantToJson(this);
}