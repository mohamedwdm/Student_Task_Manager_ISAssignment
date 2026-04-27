import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:student_task_manager/core/theme/colors.dart';
import 'package:student_task_manager/core/theme/spacing.dart';
import 'package:student_task_manager/core/theme/text_styles.dart';
import 'package:student_task_manager/features/auth/presentation/manager/auth_cubit.dart';
import 'package:student_task_manager/features/auth/presentation/manager/auth_state.dart';
import 'package:student_task_manager/features/tasks/data/models/task_model.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/task_cubit.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/task_state.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/favorite_cubit.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/favorite_state.dart';
import 'package:student_task_manager/core/widgets/bottom_nav_bar.dart';
import 'package:student_task_manager/features/tasks/presentation/views/widgets/tasks/task_card.dart';

class FavoriteTasksView extends StatelessWidget {
  const FavoriteTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'FAVORITES',
          style: AppTextStyles.titleMedium.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, favState) {
          if (favState is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favState is FavoriteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(favState.message, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is AuthSuccess) {
                        context.read<FavoriteCubit>().init(authState.user.id!);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final List<TaskModel> favoriteTasks;
          if (favState is FavoriteLoaded) {
            favoriteTasks = favState.favoriteTasks;
          } else {
            favoriteTasks = [];
          }

          if (favoriteTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppColors.outline.withOpacity(0.4),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'No favorite tasks yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: favoriteTasks.size,
            itemBuilder: (context, index) {
              final task = favoriteTasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.l),
                child: TaskCard(
                  task: task,
                  onToggle: () =>
                      context.read<TaskCubit>().toggleComplete(task),
                  onEdit: () => context.push('/edit-task', extra: task),
                  onDelete: () =>
                      context.read<TaskCubit>().deleteTask(task.id!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension on List {
  int get size => length;
}
