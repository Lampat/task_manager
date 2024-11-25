import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task_model.dart';

void main() {
  group(
    'Task Model Tests',
    () {
      test(
        'Test if the toMap serializes a Task to a Map',
        () {
          final task = Task(
            id: '1',
            title: 'Test title for first Task',
            description: 'This is a test description for the first Task',
            category: TaskCategory.work,
            dueDate: DateTime.parse('2024-11-27T15:30:00.000'),
            priority: TaskPriority.high,
            reminderTime: null,
          );

          final taskMap = task.toMap();

          expect(taskMap, {
            'title': 'Test title for first Task',
            'description': 'This is a test description for the first Task',
            'category': 'work',
            'dueDate': '2024-11-27T15:30:00.000',
            'priority': 'high',
            'reminderTime': null,
          });
        },
      );

      test(
        'Test if the fromMap deserializes a Map to a Task',
        () {
          final taskMap = {
            'title': 'Test title for second Task',
            'description': 'This is a test description for the second Task',
            'dueDate': '2024-11-29T21:55:00.000',
            'category': 'personal',
            'priority': 'low',
            'reminderTime': '2024-11-28T21:55:00.000',
          };

          final task = Task.fromMap('2', taskMap);

          expect(task.id, '2');
          expect(task.title, 'Test title for second Task');
          expect(task.description,
              'This is a test description for the second Task');
          expect(task.dueDate, DateTime.parse('2024-11-29T21:55:00.000'));
          expect(task.category, TaskCategory.personal);
          expect(task.priority, TaskPriority.low);
          expect(task.reminderTime, DateTime.parse('2024-11-28T21:55:00.000'));
        },
      );
    },
  );
}
