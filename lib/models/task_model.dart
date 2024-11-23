enum TaskCategory { work, personal, other }

enum TaskPriority { high, medium, low }

extension TaskCategoryExtension on TaskCategory {
  // Convert enum to string for Firestore
  String toFirestoreString() {
    return name; // 'work', 'personal', 'other'
  }

  // Convert string from Firestore to enum
  static TaskCategory fromFirestoreString(String value) {
    return TaskCategory.values.firstWhere((e) => e.name == value);
  }
}

extension TaskPriorityExtension on TaskPriority {
  // Convert enum to string for Firestore
  String toFirestoreString() {
    return name; // 'high', 'medium', 'low'
  }

  // Convert string from Firestore to enum
  static TaskPriority fromFirestoreString(String value) {
    return TaskPriority.values.firstWhere((e) => e.name == value);
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final DateTime dueDate;
  final TaskPriority priority; // Changed to TaskPriority

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.priority,
  });

  // Convert Task to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.toFirestoreString(),
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toFirestoreString(), // Convert enum to string
    };
  }

  // Create Task from Firestore document
  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'],
      description: data['description'],
      category: TaskCategoryExtension.fromFirestoreString(data['category']),
      dueDate: DateTime.parse(data['dueDate']),
      priority: TaskPriorityExtension.fromFirestoreString(
          data['priority']), // Convert string to enum
    );
  }
}
