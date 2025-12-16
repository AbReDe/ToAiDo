// lib/models/friend_model.dart

class Friend {
  final int id;        // İstek ID'si (Kabul/Red için)
  final int userId;    // Kişinin User ID'si
  final String username;
  final String fullName;

  Friend({required this.id, required this.userId, required this.username, required this.fullName});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      fullName: json['full_name'],
    );
  }
}