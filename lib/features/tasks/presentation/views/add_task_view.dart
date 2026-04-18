import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import 'widgets/add_task_view_body.dart';
import 'widgets/bottom_nav_bar.dart';

class AddTaskView extends StatelessWidget {
  const AddTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: AddTaskViewBody(),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
