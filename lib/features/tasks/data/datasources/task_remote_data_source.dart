import 'package:injectable/injectable.dart';

import '../../../../core/network/api_service.dart';
import '../models/task_model.dart';

@injectable
class TaskRemoteDataSource {
  final ApiService apiService;

  TaskRemoteDataSource(this.apiService);

  Future<List<dynamic>> getRemoteTasks(int userId) async {
    return await apiService.get('/users/$userId/tasks');
  }

  Future<dynamic> addRemoteTask(TaskModel task) async {
    return await apiService.post('/tasks', {
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate,
      'priority': task.priority,
      'user_id': task.userId,
    });
  }

  Future<dynamic> updateRemoteTask(int taskId, TaskModel task) async {
    return await apiService.put('/tasks/$taskId', {
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate,
      'priority': task.priority,
      'user_id': task.userId,
    });
  }

  Future<dynamic> deleteRemoteTask(int taskId) async {
    return await apiService.delete('/tasks/$taskId');
  }

  Future<dynamic> toggleCompleteRemote(int taskId, bool isCompleted) async {
    return await apiService.patch('/tasks/$taskId/complete', {
      'is_completed': isCompleted,
    });
  }

  Future<dynamic> addFavorite(int taskId) async {
    return await apiService.patch('/tasks/$taskId/add-favorite', {});
  }

  Future<dynamic> removeFavorite(int taskId) async {
    return await apiService.patch('/tasks/$taskId/remove-favorite', {});
  }

  Future<List<dynamic>> getFavorites(int userId) async {
    return await apiService.get('/users/$userId/favorites');
  }

  Future<dynamic> getDeadline(int taskId) async {
    return await apiService.get('/tasks/$taskId/deadline');
  }
}
