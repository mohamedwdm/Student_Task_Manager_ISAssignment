import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isDestructive;
  final bool isLoading;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isDestructive = false,
    this.isLoading = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    final bgColor =
        isDisabled
            ? AppColors.surfaceContainerHigh
            : isDestructive
            ? AppColors.errorContainer
            : isPrimary
            ? AppColors.primary
            : AppColors.surfaceContainerHigh;

    final fgColor =
        textColor ??
        (isDisabled
            ? AppColors.outline
            : isDestructive
            ? const Color(0xFF93000A)
            : isPrimary
            ? AppColors.onPrimary
            : AppColors.primary);

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.circular),
    );

    final style = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      shape: shape,
      elevation: 0,
    );

    Widget content;

    if (isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: fgColor)),
        ],
      );
    } else {
      content = Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: fgColor),
      );
    }

    return ElevatedButton(
      style: style,
      onPressed: isDisabled ? null : onPressed,
      child: content,
    );
  }
}
