// lib/models/user_profile_model.dart

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final int totalTasks;     // İstatistik
  final int completedTasks; // İstatistik
  final int friendsCount;   // İstatistik

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.friendsCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      friendsCount: json['friends_count'] ?? 0,
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
    };
  }
}