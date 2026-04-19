import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../../../core/database/task_dao.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

@lazySingleton
class SyncService {
  final TaskDao taskDao;
  final TaskRemoteDataSource remoteDataSource;

  SyncService(this.taskDao, this.remoteDataSource) {
    _startSyncTimer();
  }

  bool _isSyncing = false;
  Timer? _syncTimer;
  final _syncCompleteController = StreamController<void>.broadcast();
  
  Stream<void> get onSyncComplete => _syncCompleteController.stream;

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      syncPendingTasks();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncCompleteController.close();
  }

  Future<void> syncPendingTasks() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      print('DEBUG SYNC: Starting background sync check...');
      final unsyncedMaps = await taskDao.getUnsyncedTasks();
      
      if (unsyncedMaps.isEmpty) {
        print('DEBUG SYNC: No pending tasks found.');
        return;
      }

      print('DEBUG SYNC: Found ${unsyncedMaps.length} tasks to synchronize.');

      for (final map in unsyncedMaps) {
        final task = TaskModel.fromMap(map);
        await _syncSingleTask(task);
      }
      
      print('DEBUG SYNC: Background sync process complete.');
      _syncCompleteController.add(null);
    } catch (e) {
      print('DEBUG SYNC ERROR: Sync process failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncSingleTask(TaskModel task) async {
    if (task.id == null) return;

    try {
      switch (task.syncAction) {
        case 'create':
          print('DEBUG SYNC: Pushing CREATE for task ${task.id}');
          final response = await remoteDataSource.addRemoteTask(task);
          // If server returns a new ID, we update the local record and mark as synced
          final serverId = response['id'] ?? response['user_id'];
          if (serverId != null) {
             await taskDao.deleteTask(task.id!); // Remove temp local record
             final syncedTask = TaskModel(
               id: serverId,
               userId: task.userId,
               title: task.title,
               description: task.description,
               dueDate: task.dueDate,
               priority: task.priority,
               isCompleted: task.isCompleted,
               isSynced: true,
               syncAction: null,
             );
             await taskDao.insertTask(syncedTask.toMap());
          }
          break;

        case 'update':
          print('DEBUG SYNC: Pushing UPDATE for task ${task.id}');
          await remoteDataSource.updateRemoteTask(task.id!, task);
          await taskDao.updateTask(task.id!, task.copyWith(isSynced: true, syncAction: null).toMap());
          break;

        case 'delete':
          print('DEBUG SYNC: Pushing DELETE for task ${task.id}');
          await remoteDataSource.deleteRemoteTask(task.id!);
          await taskDao.deleteTask(task.id!); // Permanently remove from local now
          break;
          
        default:
          // Just mark as synced if action is unknown or null
          await taskDao.updateTask(task.id!, task.copyWith(isSynced: true, syncAction: null).toMap());
      }
    } catch (e) {
      print('DEBUG SYNC ERROR: Failed to sync task ${task.id}: $e. Will retry later.');
    }
  }
}

extension on TaskModel {
  TaskModel copyWith({bool? isSynced, String? syncAction}) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      isCompleted: isCompleted,
      isSynced: isSynced ?? this.isSynced,
      syncAction: syncAction ?? this.syncAction,
    );
  }
}
