import 'package:flutter/material.dart';
import 'package:task_manager/models/task_model.dart';

Color priorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return Colors.redAccent;
    case TaskPriority.medium:
      return Colors.orangeAccent;
    case TaskPriority.low:
      return Colors.greenAccent;
    default:
      return Colors.blueGrey;
  }
}

Icon priorityIcon(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return const Icon(Icons.priority_high, color: Colors.black);
    case TaskPriority.medium:
      return const Icon(Icons.remove, color: Colors.black);
    case TaskPriority.low:
      return const Icon(Icons.arrow_drop_down, color: Colors.black);
    default:
      return const Icon(Icons.task, color: Colors.black);
  }
}
