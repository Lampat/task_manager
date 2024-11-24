import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/settings_screen.dart';
import 'package:task_manager/screens/task_screen.dart';
import 'package:task_manager/shared/animated_navigation.dart';
import 'package:task_manager/shared/filter_dialog.dart';
import 'package:task_manager/widgets/task_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    createAnimatedRoute(const SettingsScreen()),
                  ),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextFormField(
              onChanged: (value) => searchQuery.state = value,
              decoration: const InputDecoration(
                labelText: 'Search Tasks',
                prefixIcon: Icon(Icons.search),
                // filled: true,
                // fillColor: Colors.deepPurple[50],
                border: OutlineInputBorder(
                  // borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
          const TasksList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            createAnimatedRoute(const AddEditTaskScreen()),
          );
        },
      ),
    );
  }
}
