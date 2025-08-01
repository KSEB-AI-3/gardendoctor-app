// lib/models/user_plant_request_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'user_plant_request_model.g.dart';

@JsonSerializable()
class UserPlantRequest {
  final String plantName;         // 식물 종류 (선택 또는 직접 입력)
  final String plantNickname;     // 식물 별명
  final int gardenUniqueId;       // 텃밭 고유 ID (일단 '기타'로 고정)
  final String? plantingPlace;    // 심은 장소 (사용자 입력)
  final String? plantedDate;       // 심은 날짜 (현재 시간으로 설정)
  final String? notes;             // 메모 (일단 빈 값으로 설정)

  UserPlantRequest({
    required this.plantName,
    required this.plantNickname,
    required this.gardenUniqueId,
    this.plantingPlace,
    this.plantedDate,
    this.notes,
  });

  factory UserPlantRequest.fromJson(Map<String, dynamic> json) => _$UserPlantRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserPlantRequestToJson(this);
}