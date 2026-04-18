import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import 'widgets/tasks_view_body.dart';
import 'widgets/bottom_nav_bar.dart';

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
