// lib/models/task_model.dart

class Task {
  final int? id; // Yeni eklerken null olabilir
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate; // Backend'den 'due_date' olarak geliyor
  final int? ownerId;

  Task({
    this.id,
    required this.title,
    this.description,
    this.status = "Yapılacak",
    this.priority = "medium",
    this.dueDate,
    this.ownerId,
  });

  // Backend'den gelen JSON'ı Dart objesine çevir
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? "Yapılacak",
      priority: json['priority'] ?? "medium",
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      ownerId: json['owner_id'],
    );
  }

  // Dart objesini Backend'e göndermek için JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(), // ISO 8601 formatı (Backend sever)
    };
  }
}