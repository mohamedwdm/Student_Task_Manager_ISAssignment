import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/app_avatar.dart';
import 'add_task_form.dart';

class AddTaskViewBody extends StatelessWidget {
  const AddTaskViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 80, right: -80,
          child: Container(
            width: 384, height: 384,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.05), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 100, spreadRadius: 100)]),
          ),
        ),
        Positioned(
          bottom: 80, left: -80,
          child: Container(
            width: 384, height: 384,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary.withOpacity(0.05), boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.05), blurRadius: 100, spreadRadius: 100)]),
          ),
        ),
        SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      AppAvatar(),
                      const SizedBox(width: 12),
                      const Text('Academic Curator', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: -0.5)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Add Scholarly Task', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: -1)),
                      SizedBox(height: 8),
                      Text('Curate your academic focus with editorial precision.', style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.onSurfaceVariant))
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: const AddTaskForm(),
                    ),
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        ),
      ],
    );
  }
}
