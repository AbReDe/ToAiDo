// lib/models/task_model.dart

class Task {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final int? ownerId;
  final String? ownerName;
  final int? projectId; // Projeden gelip gelmediğini anlamak için

  // --- YENİ EKLENENLER ---
  final String? repeat; // "daily", "weekly", "none"
  final List<String> tags; // ["yazılım", "spor"]

  final List<String> completedDates;
  // -----------------------

  Task({
    this.id,
    required this.title,
    this.description,
    this.status = "Yapılacak",
    this.priority = "medium",
    this.dueDate,
    this.ownerId,
    this.ownerName,
    this.projectId,
    this.repeat = "none",
    this.tags = const [],
    this.completedDates = const [],

  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? "Yapılacak",
      priority: json['priority'] ?? "medium",
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      ownerId: json['owner_id'],
      ownerName: json['owner'] != null ? json['owner']['full_name'] : null,
      projectId: json['project_id'],

      // JSON'dan okuma (Backend henüz göndermiyor olabilir, güvenli okuyalım)
      repeat: json['repeat'] ?? "none",
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      completedDates: json['completed_dates'] != null
          ? List<String>.from(json['completed_dates'])
          : [],
    );

  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'repeat': repeat, // Gönderiyoruz
      'tags': tags,     // Gönderiyoruz
    };
  }
}