import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../data/models/task_model.dart';
import '../../manager/task_cubit.dart';

class EditTaskForm extends StatefulWidget {
  final TaskModel taskToEdit;
  const EditTaskForm({super.key, required this.taskToEdit});

  @override
  State<EditTaskForm> createState() => _EditTaskFormState();
}

class _EditTaskFormState extends State<EditTaskForm> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _dateController;
  late String _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit.title);
    _descController = TextEditingController(
      text: widget.taskToEdit.description ?? '',
    );
    _dateController = TextEditingController(text: widget.taskToEdit.dueDate);
    _priority = widget.taskToEdit.priority.toLowerCase();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final updatedTask = TaskModel(
      id: widget.taskToEdit.id,
      userId: widget.taskToEdit.userId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _dateController.text,
      priority: _priority,
      isCompleted: widget.taskToEdit.isCompleted,
    );

    context.read<TaskCubit>().updateTask(updatedTask);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _titleController,
                label: 'TASK TITLE',
                hintText: 'e.g., Thesis Literature Review',
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                controller: _descController,
                label: 'DESCRIPTION',
                hintText:
                    'Synthesize current research on ethereal UI patterns...',
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xl),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  final dateWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('DUE DATE', style: AppTextStyles.labelSmall),
                      const SizedBox(height: AppSpacing.s),
                      _buildDateField(),
                    ],
                  );

                  final priorityWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('PRIORITY LEVEL', style: AppTextStyles.labelSmall),
                      const SizedBox(height: AppSpacing.s),
                      _buildPrioritySelector(),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: dateWidget),
                        const SizedBox(width: 24),
                        Expanded(child: priorityWidget),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      dateWidget,
                      const SizedBox(height: 24),
                      priorityWidget,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'Update Task',
                onPressed: _submit,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              flex: 1,
              child: AppButton(
                label: 'Cancel',
                isPrimary: false,
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final initial =
            DateTime.tryParse(_dateController.text) ?? DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            _dateController.text = date.toIso8601String().split('T').first;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              _dateController.text,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _buildPriorityOption('low', 'Low'),
          _buildPriorityOption('medium', 'Med'),
          _buildPriorityOption('high', 'High'),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(String value, String label) {
    final isSelected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: Container(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.surfaceContainerLowest
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: const Color(0xFF001F2A).withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ]
                    : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
