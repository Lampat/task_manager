import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/models/task_filter.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/task_provider.dart';

Future<void> showFilterDialog(BuildContext context, WidgetRef ref) async {
  // Get the current filter state
  final currentFilter = ref.read(taskFilterProvider);

  // Local copies of the current filter values
  TaskCategory? selectedCategory = currentFilter.category;
  TaskPriority? selectedPriority = currentFilter.priority;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Tasks'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown for categories
                DropdownButton<TaskCategory>(
                  value: selectedCategory,
                  hint: const Text('Select Category'),
                  isExpanded: true,
                  items: TaskCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category.name[0].toUpperCase() +
                            category.name.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value; // Update state
                    });
                  },
                ),

                // Dropdown for priorities
                DropdownButton<TaskPriority>(
                  value: selectedPriority,
                  hint: const Text('Select Priority'),
                  isExpanded: true,
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(
                        priority.name[0].toUpperCase() +
                            priority.name.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value; // Update state
                    });
                  },
                ),
              ],
            ),
            actions: [
              // Clear button
              TextButton(
                onPressed: () {
                  ref.read(taskFilterProvider.notifier).state = TaskFilter(
                    category: null,
                    priority: null,
                  ); // Clear filters
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),

              // Apply button
              TextButton(
                onPressed: () {
                  ref.read(taskFilterProvider.notifier).state = TaskFilter(
                    category: selectedCategory,
                    priority: selectedPriority,
                  ); // Apply filters
                  Navigator.of(context).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}
