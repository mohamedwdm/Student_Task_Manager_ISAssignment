import 'package:injectable/injectable.dart';

import 'task_repo.dart';
import '../models/task_model.dart';
import '../../../../core/database/task_dao.dart';
import '../datasources/task_remote_data_source.dart';

import '../services/sync_service.dart';

@Injectable(as: TaskRepo)
class TaskRepoImpl implements TaskRepo {
  final TaskDao taskDao;
  final TaskRemoteDataSource remoteDataSource;
  final SyncService syncService;

  TaskRepoImpl(this.taskDao, this.remoteDataSource, this.syncService);

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
    syncService.syncPendingTasks().ignore(); // Also check for any old pending tasks
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
    // 1. Instantly save to local DB with 'create' action
    final taskToQueue = task.copyWith(
      isSynced: false,
      syncAction: 'create',
    );
    
    final localId = await taskDao.insertTask(taskToQueue.toMap());
    final taskWithLocalId = taskToQueue.copyWith(id: localId);
    
    // 2. Trigger background sync
    syncService.syncPendingTasks().ignore();

    return taskWithLocalId;
  }


  @override
  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) return;
    
    // 1. Instantly update local SQL with 'update' action
    final taskToQueue = task.copyWith(
      isSynced: false,
      syncAction: 'update',
    );
    await taskDao.updateTask(task.id!, taskToQueue.toMap());

    // 2. Trigger background sync
    syncService.syncPendingTasks().ignore();
  }

  @override
  Future<void> deleteTask(int taskId) async {
    // 1. Mark for deletion in local SQL (Offline First)
    // We don't remove it yet so we have the record to sync the DELETE call
    await taskDao.updateTask(taskId, {
      'is_synced': 0,
      'sync_action': 'delete',
    });

    // 2. Trigger background sync
    syncService.syncPendingTasks().ignore();
  }

  @override
  Future<void> toggleComplete(TaskModel task) async {
    if (task.id == null) return;

    final isCompleted = !task.isCompleted;
    final updatedTask = task.copyWith(
      isCompleted: isCompleted,
      isSynced: false,
      syncAction: 'update',
    );
    
    // 1. Instantly update local SQL
    await taskDao.updateTask(task.id!, updatedTask.toMap());

    // 2. Trigger background sync
    syncService.syncPendingTasks().ignore();
  }
}
