import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repos/task_repo.dart';
import 'favorite_state.dart';

@injectable
class FavoriteCubit extends Cubit<FavoriteState> {
  final TaskRepo taskRepo;
  final SharedPreferences sharedPreferences;
  int? _userId;

  FavoriteCubit(this.taskRepo, this.sharedPreferences) : super(FavoriteInitial());

  void init(int userId) {
    _userId = userId;
    _loadLocalFavorites();
    _fetchRemoteFavorites();
  }

  void _loadLocalFavorites() {
    final List<String>? storedIds = sharedPreferences.getStringList('favorite_task_ids');
    if (storedIds != null) {
      final ids = storedIds.map((id) => int.parse(id)).toList();
      emit(FavoriteLoaded(favoriteIds: ids, favoriteTasks: []));
    }
  }

  Future<void> _fetchRemoteFavorites() async {
    if (_userId == null) return;
    try {
      final tasks = await taskRepo.getFavorites(_userId!);
      final ids = tasks.map((t) => t.id!).toList();
      emit(FavoriteLoaded(favoriteIds: ids, favoriteTasks: tasks));
      _saveLocalFavorites(ids);
    } catch (e) {
      // Keep local if remote fails
    }
  }

  Future<void> _saveLocalFavorites(List<int> ids) async {
    final List<String> idsToStore = ids.map((id) => id.toString()).toList();
    await sharedPreferences.setStringList('favorite_task_ids', idsToStore);
  }

  bool isFavorite(int taskId) {
    if (state is FavoriteLoaded) {
      return (state as FavoriteLoaded).favoriteIds.contains(taskId);
    }
    return false;
  }

  Future<void> toggleFavorite(int taskId) async {
    if (state is FavoriteLoaded) {
      final currentLoaded = state as FavoriteLoaded;
      final newIds = List<int>.from(currentLoaded.favoriteIds);
      
      if (newIds.contains(taskId)) {
        newIds.remove(taskId);
        await taskRepo.removeFavorite(taskId);
      } else {
        newIds.add(taskId);
        await taskRepo.addFavorite(taskId);
      }

      emit(FavoriteLoaded(
        favoriteIds: newIds,
        favoriteTasks: currentLoaded.favoriteTasks, // Will refresh on next fetch
      ));
      _saveLocalFavorites(newIds);
    }
  }
}
