import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/models/task_filter.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:collection/collection.dart';

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

class TaskService {
  final FirebaseFirestore firestore;

  TaskService(this.firestore);

  String userTasksPath(String userId) {
    return 'users/$userId/tasks';
  }

  // Fetch all tasks
  Stream<List<Task>> getTasks(String userId) {
    final path = userTasksPath(userId);
    return firestore.collection(path).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Create a new task for a specific user
  Future<void> createTask(String userId, Task task) async {
    final path = userTasksPath(userId);
    await firestore.collection(path).add(task.toMap());
  }

  // Update an existing task for a specific user
  Future<void> updateTask(String userId, Task task) async {
    final path = userTasksPath(userId);
    await firestore.collection(path).doc(task.id).update(task.toMap());
  }

  // Delete a task for a specific user
  Future<void> deleteTask(String userId, String taskId) async {
    final path = userTasksPath(userId);
    await firestore.collection(path).doc(taskId).delete();
  }
}
