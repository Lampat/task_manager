import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/task_screen.dart';
import 'package:task_manager/shared/animated_navigation.dart';
import 'package:task_manager/shared/delete_dialog.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({
    super.key,
    required this.category,
    required this.tasksInCategory,
  });

  final TaskCategory category;
  final List<Task> tasksInCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      title: Text(
        category.name[0].toUpperCase() + category.name.substring(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: tasksInCategory.map((task) {
        return ListTile(
          title: Text(task.title),
          subtitle: Row(
            children: [
              Text(
                'Priority: ${task.priority.name[0].toUpperCase() + task.priority.name.substring(1)}',
              ),
              const Spacer(),
              Text(
                'Due: ${task.dueDate.toLocal()}'.split('.')[0],
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.deepPurple[300],
            onPressed: () async {
              final userId = ref.read(getUserIdProvider);
              final confirmDelete = await deleteDialog(context, task.title);
              if (confirmDelete) {
                ref.read(taskServiceProvider).deleteTask(userId ?? "", task.id);
              }
            },
          ),
          onTap: () {
            Navigator.push(
                context, createAnimatedRoute(AddEditTaskScreen(task: task)));
          },
        );
      }).toList(),
    );
  }
}
