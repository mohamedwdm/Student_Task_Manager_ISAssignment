import '../models/task_model.dart';

abstract class TaskRepo {
  Future<List<TaskModel>> getTasks(int userId, {bool forceRefresh = false});
  Future<TaskModel> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(int taskId);
  Future<void> toggleComplete(TaskModel task);
}
