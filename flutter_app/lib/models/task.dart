// lib/models/task_model.dart

class Task {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final int? ownerId;
  final String? ownerName; // <-- YENİ: Görevi alan kişinin adı

  Task({
    this.id,
    required this.title,
    this.description,
    this.status = "Yapılacak",
    this.priority = "medium",
    this.dueDate,
    this.ownerId,
    this.ownerName,
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
      // Backend'den 'owner' objesi gelirse içindeki 'full_name'i al, yoksa null
      ownerName: json['owner'] != null ? json['owner']['full_name'] : null,
    );
  }

  // toJson kısmı aynı kalabilir...
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}