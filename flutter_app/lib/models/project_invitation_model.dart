// lib/models/project_invitation_model.dart

class ProjectInvitation {
  final int id;
  final int projectId;
  final String projectName;
  final String senderUsername;
  final String status;

  ProjectInvitation({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.senderUsername,
    required this.status,
  });

  factory ProjectInvitation.fromJson(Map<String, dynamic> json) {
    return ProjectInvitation(
      id: json['id'],
      projectId: json['project_id'],
      projectName: json['project_name'],
      senderUsername: json['sender_username'],
      status: json['status'],
    );
  }
}