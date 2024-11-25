import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/models/task_filter.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:collection/collection.dart';
import 'package:task_manager/services/task_service.dart';

// Provider for Firestore instance
final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Provider for TaskService using firestore
final taskServiceProvider = Provider<TaskService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TaskService(firestore);
});

// Stream Provider for tasks in firestore
final tasksProvider = StreamProvider<List<Task>>((ref) {
  final taskService = ref.watch(taskServiceProvider);
  final userId = ref.watch(getUserIdProvider);
  return taskService.getTasks(userId ?? "");
});

// Provider to use search functionality for tasks
final searchQueryProvider = StateProvider<String>((ref) => "");

// Provider to use a filter on tasks
final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return TaskFilter(category: null, priority: null);
});

// Provider to get the tasks based on filter/search parameters
final groupedTasksProvider =
    Provider<AsyncValue<Map<TaskCategory, List<Task>>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final filter = ref.watch(taskFilterProvider);

  // Handle the AsyncValue state
  return tasksAsync.when(
    data: (tasks) {
      // Tasks considering the search query and filtering
      final filteredTasks = tasks.where((task) {
        final matchesQuery =
            task.title.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesCategory =
            filter.category == null || task.category == filter.category;
        final matchesPriority =
            filter.priority == null || task.priority == filter.priority;
        return matchesQuery && matchesCategory && matchesPriority;
      }).toList();

      // Group filtered tasks
      final groupedTasks = groupBy<Task, TaskCategory>(
        filteredTasks,
        (task) => task.category,
      );

      // Sort tasks by priority within each category
      groupedTasks.forEach((category, tasksInCategory) {
        tasksInCategory
            .sort((a, b) => a.priority.index.compareTo(b.priority.index));
      });

      return AsyncValue.data(groupedTasks);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
