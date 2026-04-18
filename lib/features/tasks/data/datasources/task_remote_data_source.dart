import 'package:injectable/injectable.dart';

import '../../../../core/network/api_service.dart';
import '../models/task_model.dart';

@injectable
class TaskRemoteDataSource {
  final ApiService apiService;

  TaskRemoteDataSource(this.apiService);

  Future<List<dynamic>> getRemoteTasks(int userId) async {
    return await apiService.get('/tasks/$userId');
  }

  Future<dynamic> addRemoteTask(TaskModel task) async {
    return await apiService.post('/tasks', task.toJson());
  }

  Future<dynamic> updateRemoteTask(int taskId, TaskModel task) async {
    return await apiService.put('/tasks/$taskId', task.toJson());
  }

  Future<dynamic> deleteRemoteTask(int taskId) async {
    return await apiService.delete('/tasks/$taskId');
  }
}
