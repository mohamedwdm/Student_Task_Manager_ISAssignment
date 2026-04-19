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
  Future<List<TaskModel>> getTasks(int userId) async {
    // 1. Fire off remote sync silently in the background
    _syncTasksFromRemote(userId).ignore();

    // 2. Instantly return local cached data to the UI
    final localData = await taskDao.getTasksByUserId(userId);
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
    // 1. Instantly save to local DB
    final id = await taskDao.insertTask(task.toMap());
    final newTaskWithId = TaskModel(
      id: id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: task.isCompleted,
    );
    
    // 2. Fire and forget remote action
    _addRemoteTaskBackground(newTaskWithId).ignore();

    // 3. Return the new task immediately with local SQLite ID
    return newTaskWithId;
  }

  Future<void> _addRemoteTaskBackground(TaskModel task) async {
    try {
      await remoteDataSource.addRemoteTask(task);
    } catch (e) {
      // Ignored handling for true local-first
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) return;
    
    // 1. Instantly update local SQL
    await taskDao.updateTask(task.id!, task.toMap());

    // 2. Fire and forget remote action
    _updateRemoteTaskBackground(task.id!, task).ignore();
  }

  Future<void> _updateRemoteTaskBackground(int id, TaskModel task) async {
    try {
      await remoteDataSource.updateRemoteTask(id, task);
    } catch (e) {}
  }

  @override
  Future<void> deleteTask(int taskId) async {
    // 1. Instantly delete from local SQL
    await taskDao.deleteTask(taskId);

    // 2. Fire and forget remote action
    _deleteRemoteTaskBackground(taskId).ignore();
  }

  Future<void> _deleteRemoteTaskBackground(int taskId) async {
    try {
      await remoteDataSource.deleteRemoteTask(taskId);
    } catch (e) {}
  }

  @override
  Future<void> toggleComplete(TaskModel task) async {
    final updatedTask = TaskModel(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: !task.isCompleted,
    );
    
    // 1. Instantly update local SQL
    if (updatedTask.id != null) {
      await taskDao.updateTask(updatedTask.id!, updatedTask.toMap());
    }

    // 2. Fire and forget remote action (using specific PATCH endpoint)
    if (updatedTask.id != null) {
      _toggleCompleteRemoteBackground(updatedTask.id!, updatedTask.isCompleted).ignore();
    }
  }

  Future<void> _toggleCompleteRemoteBackground(int id, bool isCompleted) async {
    try {
      await remoteDataSource.toggleCompleteRemote(id, isCompleted);
    } catch (e) {}
  }
}
