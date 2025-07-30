// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) => Plant(
      plantId: (json['plantId'] as num).toInt(),
      name: json['name'] as String?,
      englishName: json['englishName'] as String?,
      species: json['species'] as String?,
      season: json['season'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
      'plantId': instance.plantId,
      'name': instance.name,
      'englishName': instance.englishName,
      'species': instance.species,
      'season': instance.season,
      'imageUrl': instance.imageUrl,
    };
