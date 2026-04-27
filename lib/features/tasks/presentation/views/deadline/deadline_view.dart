import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:student_task_manager/core/theme/colors.dart';
import 'package:student_task_manager/core/theme/spacing.dart';
import 'package:student_task_manager/core/theme/text_styles.dart';
import 'package:student_task_manager/core/widgets/app_card.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/task_cubit.dart';
import 'package:student_task_manager/features/tasks/presentation/manager/task_state.dart';
import 'package:student_task_manager/features/tasks/data/models/task_model.dart';
import 'package:student_task_manager/core/widgets/bottom_nav_bar.dart';

class DeadlineView extends StatefulWidget {
  const DeadlineView({super.key});

  @override
  State<DeadlineView> createState() => _DeadlineViewState();
}

class _DeadlineViewState extends State<DeadlineView> {
  TaskModel? _selectedTask;

  String _calculateRemainingTime(String dueDateStr) {
    try {
      final dueDate = DateTime.parse(dueDateStr);
      final now = DateTime.now();
      final difference = dueDate.difference(now);

      if (difference.isNegative) {
        return 'Expired';
      }

      if (difference.inDays >= 1) {
        return '${difference.inDays} days';
      } else {
        return '${difference.inHours} hours';
      }
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'DEADLINE TRACKER',
          style: AppTextStyles.titleMedium.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is! TaskLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = state.allTasks;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT TASK',
                  style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outline.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TaskModel>(
                      value: tasks.contains(_selectedTask)
                          ? _selectedTask
                          : null,
                      isExpanded: true,
                      hint: const Text('Choose a task'),
                      items: tasks.map((task) {
                        return DropdownMenuItem(
                          value: task,
                          child: Text(task.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTask = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_selectedTask != null) ...[
                  AppCard(
                    backgroundColor: AppColors.surfaceContainerLowest,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTask!.title,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Deadline',
                          DateFormat(
                            'MMMM d, yyyy',
                          ).format(DateTime.parse(_selectedTask!.dueDate)),
                          Icons.calendar_today,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Today',
                          DateFormat('MMMM d, yyyy').format(DateTime.now()),
                          Icons.today,
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REMAINING TIME',
                              style: AppTextStyles.labelSmall.copyWith(
                                letterSpacing: 1.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _calculateRemainingTime(
                                          _selectedTask!.dueDate,
                                        ) ==
                                        'Expired'
                                    ? AppColors.errorContainer
                                    : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _calculateRemainingTime(
                                  _selectedTask!.dueDate,
                                ).toUpperCase(),
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _calculateRemainingTime(
                                            _selectedTask!.dueDate,
                                          ) ==
                                          'Expired'
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else
                  Expanded(
                    child: Center(
                      child: Text(
                        'Select a task to track its deadline',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
