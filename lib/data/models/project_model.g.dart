// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  ownerId: json['owner_id'] as String,
  status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'owner_id': instance.ownerId,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.notStarted: 'Not Started',
  ProjectStatus.inProgress: 'In Progress',
  ProjectStatus.completed: 'Completed',
};
