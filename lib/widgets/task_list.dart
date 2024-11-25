import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/widgets/task_tile.dart';

class TasksList extends ConsumerWidget {
  const TasksList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTasksAsync = ref.watch(groupedTasksProvider);

    return Expanded(
      child: groupedTasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: tasks.keys.length,
            itemBuilder: (context, index) {
              final category = tasks.keys.toList()[index];
              final tasksInCategory = tasks[category]!;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ExpansionTile(
                  shape: Border.all(color: Colors.transparent),
                  title: Text(
                    category.name[0].toUpperCase() + category.name.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: tasksInCategory.map((task) {
                    return TaskTile(task: task);
                  }).toList(),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
