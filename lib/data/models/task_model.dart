import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

enum TaskStatus {
  @JsonValue('Pending')
  pending,
  @JsonValue('In Progress')
  inProgress,
  @JsonValue('Completed')
  completed,
}

@JsonSerializable()
class TaskModel {
  final String id;
  @JsonKey(name: 'project_id')
  final String projectId;
  final String title;
  final String? description;
  final TaskStatus status;
  @JsonKey(name: 'assigned_to_id')
  final String? assignedToId;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  final int priority;
  @JsonKey(name: 'is_ai_generated')
  final bool isAiGenerated;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    this.assignedToId,
    this.dueDate,
    required this.priority,
    required this.isAiGenerated,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}