import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.backgroundColor = AppColors.surfaceContainerLowest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001F2A).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
