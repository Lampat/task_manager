import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/globals.dart';
import 'package:task_manager/models/task_model.dart';

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
    try {
      await firestore.collection(path).add(task.toMap());
    } catch (e) {
      snackbarKey.currentState?.showSnackBar(
          globalSnackBar("Some error occurred, please try again later."));
    }
  }

  // Update an existing task for a specific user
  Future<void> updateTask(String userId, Task task) async {
    final path = userTasksPath(userId);
    try {
      await firestore.collection(path).doc(task.id).update(task.toMap());
    } catch (e) {
      snackbarKey.currentState?.showSnackBar(
          globalSnackBar("Some error occurred, please try again later."));
    }
  }

  // Delete a task for a specific user
  Future<void> deleteTask(String userId, String taskId) async {
    final path = userTasksPath(userId);
    try {
      await firestore.collection(path).doc(taskId).delete();
    } catch (e) {
      snackbarKey.currentState?.showSnackBar(
          globalSnackBar("Some error occurred, please try again later."));
    }
  }
}
