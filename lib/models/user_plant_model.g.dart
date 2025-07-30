// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_plant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPlantResponse _$UserPlantResponseFromJson(Map<String, dynamic> json) =>
    UserPlantResponse(
      userPlantId: (json['userPlantId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      plantName: json['plantName'] as String?,
      nickname: json['nickname'] as String?,
      plantingPlace: json['plantingPlace'] as String?,
      plantedDate: json['plantedDate'] as String?,
      notes: json['notes'] as String?,
      userPlantImageUrl: json['userPlantImageUrl'] as String?,
      plantEnglishName: json['plantEnglishName'] as String?,
      species: json['species'] as String?,
      season: json['season'] as String?,
      plantImageUrl: json['plantImageUrl'] as String?,
    );

Map<String, dynamic> _$UserPlantResponseToJson(UserPlantResponse instance) =>
    <String, dynamic>{
      'userPlantId': instance.userPlantId,
      'userId': instance.userId,
      'plantName': instance.plantName,
      'nickname': instance.nickname,
      'plantingPlace': instance.plantingPlace,
      'plantedDate': instance.plantedDate,
      'notes': instance.notes,
      'userPlantImageUrl': instance.userPlantImageUrl,
      'plantEnglishName': instance.plantEnglishName,
      'species': instance.species,
      'season': instance.season,
      'plantImageUrl': instance.plantImageUrl,
    };
