// lib/models/user_profile_model.dart

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? fullName;

  // --- YENİ EKLENEN ---
  final String? avatarUrl;
  // --------------------

  final int totalTasks;
  final int completedTasks;
  final int friendsCount;
  final String? geminiApiKey;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl, // Constructor'a ekle
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.friendsCount = 0,
    this.geminiApiKey,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],

      // --- JSON OKUMA ---
      avatarUrl: json['avatar_url'],
      // ------------------

      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      friendsCount: json['friends_count'] ?? 0,
      geminiApiKey: json['gemini_api_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
    };
  }
}