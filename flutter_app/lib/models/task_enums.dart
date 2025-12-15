// lib/models/task_enums.dart

enum TaskStatus {
  todo,
  in_progress,
  review,
  done
}

enum TaskPriority {
  low,
  medium,
  high
}

// Backend'den gelen string'i Enum'a çevirmek için yardımcı fonksiyonlar
TaskStatus stringToTaskStatus(String status) {
  return TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
    orElse: () => TaskStatus.todo,
  );
}

TaskPriority stringToTaskPriority(String priority) {
  return TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == priority,
    orElse: () => TaskPriority.medium,
  );
}