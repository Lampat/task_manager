import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/settings_screen.dart';
import 'package:task_manager/screens/task_screen.dart';
import 'package:task_manager/shared/filter_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTasksAsync = ref.watch(groupedTasksProvider);
    final searchQuery = ref.watch(searchQueryProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showFilterDialog(context, ref),
          ),
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => searchQuery.state = value,
              decoration: const InputDecoration(
                labelText: 'Search Tasks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
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

                    return ExpansionTile(
                      title: Text(
                        category.name[0].toUpperCase() +
                            category.name.substring(1),
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
                            color: Colors.red[400],
                            onPressed: () {
                              final userId = ref.read(getUserIdProvider);
                              ref
                                  .read(taskServiceProvider)
                                  .deleteTask(userId ?? "", task.id);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditTaskScreen(task: task)),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
      ),
    );
  }
}
