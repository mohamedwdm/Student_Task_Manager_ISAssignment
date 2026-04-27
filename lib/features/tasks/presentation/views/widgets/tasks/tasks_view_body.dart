import 'package:flutter/material.dart';
import 'package:student_task_manager/core/theme/colors.dart';
import 'package:student_task_manager/core/theme/spacing.dart';
import 'package:student_task_manager/core/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:student_task_manager/core/widgets/app_avatar.dart';
import 'package:student_task_manager/features/auth/presentation/manager/auth_cubit.dart';
import 'package:student_task_manager/features/auth/presentation/manager/auth_state.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/favorite_cubit.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/task_cubit.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/task_state.dart';

import 'task_card.dart';

class TasksViewBody extends StatefulWidget {
  const TasksViewBody({super.key});

  @override
  State<TasksViewBody> createState() => _TasksViewBodyState();
}

class _TasksViewBodyState extends State<TasksViewBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadTasksForCurrentUser(),
    );
  }

  void _loadTasksForCurrentUser() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      final user = authState.user;
      if (user.id != null) {
        context.read<TaskCubit>().init(user.id!);
        context.read<FavoriteCubit>().init(user.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current is AuthSuccess,
      listener: (context, state) {
        final user = (state as AuthSuccess).user;
        if (user.id != null) {
          context.read<TaskCubit>().init(user.id!);
          context.read<FavoriteCubit>().init(user.id!);
        }
      },
      child: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                    blurRadius: 120,
                    spreadRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryContainer.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<TaskCubit>().fetchTasks(forceRefresh: true);
              },
              backgroundColor: AppColors.surfaceContainerLowest,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Custom Header App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AppAvatar(),
                              const SizedBox(width: 12),
                              const Text(
                                'Academic Curator',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dashboard Stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                      child: BlocBuilder<TaskCubit, TaskState>(
                        builder: (context, state) {
                          int activeCount = 0;
                          double completionRate = 0;
                          if (state is TaskLoaded) {
                            final total = state.allTasks.length;
                            final completed = state.allTasks
                                .where((t) => t.isCompleted)
                                .length;
                            activeCount = total - completed;
                            if (total > 0) {
                              completionRate = (completed / total) * 100;
                            }
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final isLarge = constraints.maxWidth > 700;
                              final childContent = [
                                Expanded(
                                  flex: isLarge ? 2 : 0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DASHBOARD',
                                        style: AppTextStyles.labelMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.s),
                                      const Text(
                                        'Scholarly Focus',
                                        style: AppTextStyles.heading1,
                                      ),
                                      const SizedBox(height: AppSpacing.l),
                                      const Text(
                                        'Your curated path for academic excellence. Manage your research, assignments, and lectures with editorial precision.',
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                      if (!isLarge)
                                        const SizedBox(height: AppSpacing.xxl),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        value: activeCount.toString(),
                                        label: 'Active Tasks',
                                        bgColor: AppColors.surfaceContainerLow,
                                        valueColor: AppColors.primary,
                                        labelColor: AppColors.outline,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.l),
                                    Expanded(
                                      child: _buildStatCard(
                                        value: '${completionRate.toInt()}%',
                                        label: 'Completion',
                                        bgColor: AppColors.surfaceContainerHigh,
                                        valueColor: AppColors.secondary,
                                        labelColor: AppColors.secondary
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ];

                              if (isLarge) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: childContent,
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: childContent,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Task List section
                  BlocBuilder<TaskCubit, TaskState>(
                    builder: (context, state) {
                      if (state is TaskInitial || state is TaskLoading) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is TaskError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        );
                      } else if (state is TaskLoaded) {
                        final tasks = state.displayedTasks;

                        if (tasks.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 24.0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 48,
                                    horizontal: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(48),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 128,
                                        height: 128,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.surfaceContainerHigh,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.auto_stories,
                                            size: 48,
                                            color: AppColors.primary
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      const Text(
                                        'No Active Inquiries',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Your curriculum is clear. Use the "Add" button below to curate your next academic milestone.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 0.0,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final task = tasks[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: TaskCard(
                                  task: task,
                                  onToggle: () => context
                                      .read<TaskCubit>()
                                      .toggleComplete(task),
                                  onEdit: () =>
                                      context.push('/edit-task', extra: task),
                                  onDelete: () {
                                    if (task.id != null) {
                                      context.read<TaskCubit>().deleteTask(
                                        task.id!,
                                      );
                                    }
                                  },
                                ),
                              );
                            }, childCount: tasks.length),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                ],
              ),
            ),
          ),

          // FAB
          Positioned(
            bottom: 20,
            right: 32,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: 'fab_tasks',
                onPressed: () => context.push('/add-task'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.add_circle,
                  color: AppColors.onPrimary,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color bgColor,
    required Color valueColor,
    required Color labelColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: valueColor),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(color: labelColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
