// lib/models/diary_request_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'diary_request_model.g.dart';

@JsonSerializable()
class DiaryRequest {
  // ❗️이 필드를 List<int>로 변경
  final List<int> selectedUserPlantIds;
  final String title;
  final String content;
  final bool watered;
  final bool fertilized;
  final bool pruned;
  // ❗️date 필드는 백엔드에서 자동 생성하므로 제거

  DiaryRequest({
    required this.selectedUserPlantIds,
    required this.title,
    required this.content,
    required this.watered,
    required this.fertilized,
    required this.pruned,
  });

  factory DiaryRequest.fromJson(Map<String, dynamic> json) => _$DiaryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryRequestToJson(this);
}