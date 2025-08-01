// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_plant_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPlantRequest _$UserPlantRequestFromJson(Map<String, dynamic> json) =>
    UserPlantRequest(
      plantName: json['plantName'] as String,
      plantNickname: json['plantNickname'] as String,
      gardenUniqueId: (json['gardenUniqueId'] as num).toInt(),
      plantingPlace: json['plantingPlace'] as String?,
      plantedDate: json['plantedDate'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$UserPlantRequestToJson(UserPlantRequest instance) =>
    <String, dynamic>{
      'plantName': instance.plantName,
      'plantNickname': instance.plantNickname,
      'gardenUniqueId': instance.gardenUniqueId,
      'plantingPlace': instance.plantingPlace,
      'plantedDate': instance.plantedDate,
      'notes': instance.notes,
    };
