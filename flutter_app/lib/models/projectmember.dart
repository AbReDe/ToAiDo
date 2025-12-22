// lib/models/project_member_model.dart

class ProjectMember {
  final int id;
  final String username;
  final String fullName;
  final String? avatarUrl;

  ProjectMember({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}