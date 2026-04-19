import 'package:injectable/injectable.dart';

import 'task_repo.dart';
import '../models/task_model.dart';
import '../../../../core/database/task_dao.dart';
import '../datasources/task_remote_data_source.dart';

@Injectable(as: TaskRepo)
class TaskRepoImpl implements TaskRepo {
  final TaskDao taskDao;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepoImpl(this.taskDao, this.remoteDataSource);

  @override
  Future<List<TaskModel>> getTasks(int userId, {bool forceRefresh = false}) async {
    // 1. Get local cached data
    final localData = await taskDao.getTasksByUserId(userId);
    
    // 2. If forced or empty, we MUST wait for the sync to complete
    if (forceRefresh || localData.isEmpty) {
      print('DEBUG SYNC: Syncing tasks (Force: $forceRefresh, Empty: ${localData.isEmpty})...');
      await _syncTasksFromRemote(userId);
      final freshData = await taskDao.getTasksByUserId(userId);
      return freshData.map((e) => TaskModel.fromMap(e)).toList();
    }

    // 3. Normal load: return local instantly and sync in background
    _syncTasksFromRemote(userId).ignore();
    return localData.map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<void> _syncTasksFromRemote(int userId) async {
    try {
      final remoteData = await remoteDataSource.getRemoteTasks(userId);
      final List<Map<String, dynamic>> mappedData = List<Map<String, dynamic>>.from(remoteData);
      await taskDao.syncTasks(mappedData, userId);
    } catch (e) {
      // Background sync silently fails so it doesn't bother the user
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    // 1. Instantly save to local DB (using temporary SQLite ID)
    final localId = await taskDao.insertTask(task.toMap());
    final taskWithLocalId = TaskModel(
      id: localId,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: task.isCompleted,
    );
    
    // 2. Sync to remote immediately
    try {
      final remoteResponse = await remoteDataSource.addRemoteTask(taskWithLocalId);
      print('DEBUG: SERVER TASK RESPONSE: $remoteResponse');
      
      final dynamic serverIdRaw = remoteResponse['id'];
      int? serverId;
      if (serverIdRaw is int) serverId = serverIdRaw;
      if (serverIdRaw is String) serverId = int.tryParse(serverIdRaw);
      
      if (serverId != null) {
        print('DEBUG SYNC: Local ID $localId successfully mapped to Server ID $serverId');
        // 3. Delete the temporary local record and insert the correct server record
        await taskDao.deleteTask(localId);
        final taskWithServerId = TaskModel(
          id: serverId,
          userId: task.userId,
          title: task.title,
          description: task.description,
          dueDate: task.dueDate,
          priority: task.priority,
          isCompleted: task.isCompleted,
        );
        await taskDao.insertTask(taskWithServerId.toMap());
        return taskWithServerId;
      }
    } catch (e) {
      print('DEBUG SYNC ERROR: Failed to add task to remote: $e');
      // We still return the local task so the user can keep working offline
    }

    return taskWithLocalId;
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) return;
    
    // 1. Instantly update local SQL
    await taskDao.updateTask(task.id!, task.toMap());

    // 2. Remote action
    try {
      print('DEBUG SYNC: Attempting UPDATE on Server ID ${task.id} for User ${task.userId}');
      await remoteDataSource.updateRemoteTask(task.id!, task);
    } catch (e) {
      print('DEBUG SYNC ERROR: Failed to update task on remote: $e');
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    // 1. Instantly delete from local SQL
    await taskDao.deleteTask(taskId);

    // 2. Remote action
    try {
      print('DEBUG SYNC: Attempting DELETE on Server ID $taskId');
      await remoteDataSource.deleteRemoteTask(taskId);
    } catch (e) {
      print('DEBUG SYNC ERROR: Failed to delete task on remote: $e');
    }
  }

  @override
  Future<void> toggleComplete(TaskModel task) async {
    if (task.id == null) return;

    final isCompleted = !task.isCompleted;
    final updatedTask = TaskModel(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: isCompleted,
    );
    
    // 1. Instantly update local SQL
    await taskDao.updateTask(task.id!, updatedTask.toMap());

    // 2. Remote action (using specific PATCH endpoint)
    try {
      print('DEBUG SYNC: Attempting TOGGLE on Server ID ${task.id} to $isCompleted');
      await remoteDataSource.toggleCompleteRemote(task.id!, isCompleted);
    } catch (e) {
      print('DEBUG SYNC ERROR: Failed to toggle completion on remote: $e');
    }
  }
}
