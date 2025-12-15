class Project {
  final int id;
  final String name;
  final String? description;
  final int ownerId;
  final DateTime? createdAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['owner_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
    };
  }
}