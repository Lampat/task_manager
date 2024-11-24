import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/models/task_filter.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:collection/collection.dart';
import 'package:task_manager/services/task_service.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final taskServiceProvider = Provider<TaskService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TaskService(firestore);
});

final tasksProvider = StreamProvider<List<Task>>((ref) {
  final taskService = ref.watch(taskServiceProvider);
  final userId = ref.watch(getUserIdProvider);
  return taskService.getTasks(userId ?? "");
});

final searchQueryProvider = StateProvider<String>((ref) => "");

final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return TaskFilter(category: null, priority: null);
});

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
