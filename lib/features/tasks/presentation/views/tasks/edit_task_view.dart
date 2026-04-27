import 'package:flutter/material.dart';

import 'package:student_task_manager/core/theme/colors.dart';
import 'package:student_task_manager/features/tasks/data/models/task_model.dart';
import 'package:student_task_manager/core/widgets/bottom_nav_bar.dart';
import 'package:student_task_manager/features/tasks/presentation/views/widgets/tasks/edit_task_view_body.dart';

class EditTaskView extends StatelessWidget {
  final TaskModel taskToEdit;

  const EditTaskView({super.key, required this.taskToEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: EditTaskViewBody(taskToEdit: taskToEdit),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
