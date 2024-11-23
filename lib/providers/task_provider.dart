import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/auth_provider.dart';

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
