import 'package:task_manager/models/task_model.dart';

class TaskFilter {
  final TaskCategory? category;
  final TaskPriority? priority;

  TaskFilter({this.category, this.priority});
}
