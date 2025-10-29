// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  projectId: json['project_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  assignedToId: json['assigned_to_id'] as String?,
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
  priority: (json['priority'] as num).toInt(),
  isAiGenerated: json['is_ai_generated'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'project_id': instance.projectId,
  'title': instance.title,
  'description': instance.description,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'assigned_to_id': instance.assignedToId,
  'due_date': instance.dueDate?.toIso8601String(),
  'priority': instance.priority,
  'is_ai_generated': instance.isAiGenerated,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'Pending',
  TaskStatus.inProgress: 'In Progress',
  TaskStatus.completed: 'Completed',
};
