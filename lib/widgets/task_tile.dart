import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/task_screen.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:task_manager/shared/animated_navigation.dart';
import 'package:task_manager/shared/date_format.dart';
import 'package:task_manager/shared/delete_dialog.dart';
import 'package:task_manager/shared/priority_color.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: priorityColor(task.priority),
          child: priorityIcon(task.priority),
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            // color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority: ${task.priority.name[0].toUpperCase() + task.priority.name.substring(1)}',
            ),
            // const Spacer(),
            Text(
              'Due: ${formatIsoToReadableDate(task.dueDate.toLocal().toIso8601String())}',
              // 'Due: ${task.dueDate.toLocal()}'.split('.')[0],
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

              if (task.reminderTime != null) {
                await NotificationService().cancelNotification(task.id);
              }
            }
          },
        ),
        onTap: () {
          Navigator.push(
              context, createAnimatedRoute(AddEditTaskScreen(task: task)));
        },
      ),
    );
  }
}
