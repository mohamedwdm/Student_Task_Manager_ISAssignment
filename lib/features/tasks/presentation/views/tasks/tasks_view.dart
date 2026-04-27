import 'package:flutter/material.dart';

import 'package:student_task_manager/core/theme/colors.dart';
import 'package:student_task_manager/features/tasks/presentation/views/widgets/tasks/tasks_view_body.dart';
import 'package:student_task_manager/core/widgets/bottom_nav_bar.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: TasksViewBody()),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
    );
  }
}
