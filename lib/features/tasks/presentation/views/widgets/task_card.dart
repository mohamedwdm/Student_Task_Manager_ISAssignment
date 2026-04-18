import 'package:flutter/material.dart';
import 'package:student_task_manager/core/theme/colors.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../data/models/task_model.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeTextColor;
    String badgeText = task.priority.toUpperCase();

    if (task.isCompleted) {
      badgeColor = AppColors.outline.withOpacity(0.3);
      badgeTextColor = AppColors.outline;
      badgeText = 'COMPLETED';
    } else {
      switch (task.priority.toLowerCase()) {
        case 'high':
          badgeColor = AppColors.errorContainer;
          badgeTextColor = const Color(0xFF93000A); // on-error-container
          break;
        case 'medium':
        case 'med':
          badgeColor = AppColors.surfaceContainerHigh;
          badgeTextColor = AppColors.secondaryContainer; // Approx for medium
          break;
        case 'low':
        default:
          badgeColor = const Color(
            0xFF007F77,
          ).withOpacity(0.2); // tertiary-container approx
          badgeTextColor = const Color(0xFF00645D); // tertiary approx
          break;
      }
    }

    final dateFormat = DateFormat('MMM d, yyyy');
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(task.dueDate);
    } catch (_) {}

    final dateDisplay =
        parsedDate != null ? dateFormat.format(parsedDate) : task.dueDate;

    return AppCard(
      backgroundColor: task.isCompleted
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText,
                  style: AppTextStyles.labelSmall.copyWith(
                    letterSpacing: 2,
                    color: badgeTextColor,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!task.isCompleted)
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: AppColors.error,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (val) => onToggle(),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: AppColors.outline),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            task.isCompleted
                                ? AppColors.onSurface.withOpacity(0.6)
                                : AppColors.onSurface,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              task.isCompleted
                                  ? AppColors.onSurfaceVariant.withOpacity(0.6)
                                  : AppColors.onSurfaceVariant,
                          decoration:
                              task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.calendar_today,
                          size: 16,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateDisplay,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
