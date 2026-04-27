import 'package:flutter/material.dart';

import 'package:student_task_manager/core/theme/colors.dart';
import 'package:student_task_manager/core/widgets/bottom_nav_bar.dart';
import 'package:student_task_manager/features/tasks/presentation/views/widgets/tasks/add_task_view_body.dart';

class AddTaskView extends StatelessWidget {
  const AddTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AddTaskViewBody(),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
