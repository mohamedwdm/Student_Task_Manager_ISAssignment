import '../../data/models/task_model.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<int> favoriteIds;
  final List<TaskModel> favoriteTasks;

  FavoriteLoaded({
    required this.favoriteIds,
    required this.favoriteTasks,
  });
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}
