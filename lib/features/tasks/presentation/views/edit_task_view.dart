import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/task_model.dart';
import 'widgets/edit_task_view_body.dart';
import 'widgets/bottom_nav_bar.dart';

class EditTaskView extends StatelessWidget {
  final TaskModel taskToEdit;

  const EditTaskView({
    super.key,
    required this.taskToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: EditTaskViewBody(taskToEdit: taskToEdit),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
