import 'package:flutter_app/models/user.dart';


class ProjectMember {
  final int projectId;
  final int userId;
  final String role;
  final DateTime? joinedAt;
  final User? userDetails;

  ProjectMember({
    required this.projectId,
    required this.userId,
    this.role = 'member',
    this.joinedAt,
    this.userDetails,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      projectId: json['project_id'],
      userId: json['user_id'],
      role: json['role'] ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : null,
    
      userDetails: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}