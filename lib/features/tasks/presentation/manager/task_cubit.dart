import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'task_state.dart';
import '../../data/repos/task_repo.dart';
import '../../data/models/task_model.dart';

@injectable
class TaskCubit extends Cubit<TaskState> {
  final TaskRepo taskRepo;
  int? _currentUserId;
  String _currentFilter = 'All';

  TaskCubit(this.taskRepo) : super(TaskInitial());

  void init(int userId) {
    _currentUserId = userId;
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    if (_currentUserId == null) return;
    
    // Only show loading for the very first fetch
    if (state is! TaskLoaded) {
      emit(TaskLoading());
    }
    
    try {
      final tasks = await taskRepo.getTasks(_currentUserId!);
      _emitLoaded(tasks);
    } catch (e) {
      if (state is! TaskLoaded) {
        emit(TaskError(e.toString()));
      }
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      // Create and get the returned task containing the local ID
      final createdTask = await taskRepo.addTask(task);
      
      // Optimistically update instantly
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).allTasks;
        final updatedList = List<TaskModel>.from(currentTasks)..add(createdTask);
        _emitLoaded(updatedList);
      }
    } catch (e) {
      // Ignored for UX smoothness as per local-first standard
    }
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
    final updatedTask = TaskModel(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: !task.isCompleted,
    );

    // Call standard logic
    await updateTask(updatedTask);
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
