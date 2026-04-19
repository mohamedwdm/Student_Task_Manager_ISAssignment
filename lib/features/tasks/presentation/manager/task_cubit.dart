import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'task_state.dart';
import '../../data/repos/task_repo.dart';
import '../../data/models/task_model.dart';
import '../../data/services/sync_service.dart';

@injectable
class TaskCubit extends Cubit<TaskState> {
  final TaskRepo taskRepo;
  final SyncService syncService;
  StreamSubscription? _syncSubscription;
  int? _currentUserId;
  String _currentFilter = 'All';

  TaskCubit(this.taskRepo, this.syncService) : super(TaskInitial()) {
    _syncSubscription = syncService.onSyncComplete.listen((_) {
      print('DEBUG CUBIT: Sync complete notification received. Refreshing UI...');
      fetchTasks();
    });
  }

  void init(int userId) {
    _currentUserId = userId;
    syncService.syncPendingTasks().ignore(); // Push pending tasks on startup
    fetchTasks();
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    return super.close();
  }

  Future<void> fetchTasks({bool forceRefresh = false}) async {
    if (_currentUserId == null) return;
    
    // Only show loading for the very first fetch or force refresh
    if (state is! TaskLoaded || forceRefresh) {
      emit(TaskLoading());
    }
    
    try {
      final tasks = await taskRepo.getTasks(_currentUserId!, forceRefresh: forceRefresh);
      _emitLoaded(tasks);
    } catch (e) {
      if (state is! TaskLoaded) {
        emit(TaskError(e.toString()));
      }
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      // 1. Repo method now waits for server response and returns task with Server ID
      final createdTask = await taskRepo.addTask(task);
      
      // 2. Update state with the server-verified task
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).allTasks;
        // Check if it already exists (unlikely in this flow but safe)
        final updatedList = List<TaskModel>.from(currentTasks)..add(createdTask);
        _emitLoaded(updatedList);
      }
    } catch (e) {}
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await taskRepo.updateTask(task);
      
      // Optimistically update instantly
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).allTasks;
        final index = currentTasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          final updatedList = List<TaskModel>.from(currentTasks);
          updatedList[index] = task;
          _emitLoaded(updatedList);
        }
      }
    } catch (e) {}
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await taskRepo.deleteTask(taskId);
      
      // Optimistically update instantly
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).allTasks;
        final updatedList = List<TaskModel>.from(currentTasks)..removeWhere((t) => t.id == taskId);
        _emitLoaded(updatedList);
      }
    } catch (e) {}
  }

  Future<void> toggleComplete(TaskModel task) async {
    try {
      // 1. Call the specific repo method that handles the PATCH call
      await taskRepo.toggleComplete(task);

      // 2. Update local state optimistically
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).allTasks;
        final index = currentTasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          final updatedList = List<TaskModel>.from(currentTasks);
          final oldTask = updatedList[index];
          updatedList[index] = oldTask.copyWith(
            isCompleted: !oldTask.isCompleted,
            isSynced: false,
            syncAction: 'update',
          );
          _emitLoaded(updatedList);
        }
      }
    } catch (e) {}
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    if (state is TaskLoaded) {
      final allTasks = (state as TaskLoaded).allTasks;
      _emitLoaded(allTasks);
    }
  }

  void _emitLoaded(List<TaskModel> allTasks) {
    // Sort logic
    allTasks.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      return a.dueDate.compareTo(b.dueDate);
    });

    List<TaskModel> filtered;
    if (_currentFilter == 'Pending') {
      filtered = allTasks.where((t) => !t.isCompleted).toList();
    } else if (_currentFilter == 'Completed') {
      filtered = allTasks.where((t) => t.isCompleted).toList();
    } else {
      filtered = List.from(allTasks);
    }

    emit(TaskLoaded(allTasks, filtered, _currentFilter));
  }
}
