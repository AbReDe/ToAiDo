// lib/models/project_member_model.dart

class ProjectMember {
  final int id;
  final String username;
  final String fullName;

  ProjectMember({
    required this.id,
    required this.username,
    required this.fullName,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
    );
  }
}