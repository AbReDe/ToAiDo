class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? geminiApiKey;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.geminiApiKey,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      geminiApiKey: json['gemini_api_key'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'gemini_api_key': geminiApiKey,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}