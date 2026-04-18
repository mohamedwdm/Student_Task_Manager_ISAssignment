import '../../data/models/task_model.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> allTasks;
  final List<TaskModel> displayedTasks;
  final String filter; // 'All', 'Pending', 'Completed'

  TaskLoaded(this.allTasks, this.displayedTasks, this.filter);
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
