import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

// API'dan gelen string değerleri bu enum'a dönüştüreceğiz
enum ProjectStatus {
  @JsonValue('Not Started')
  notStarted,
  @JsonValue('In Progress')
  inProgress,
  @JsonValue('Completed')
  completed,
}

@JsonSerializable()
class ProjectModel {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'owner_id')
  final String ownerId;
  final ProjectStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.title,
    this.description,
    required this.ownerId,
    required this.status,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}