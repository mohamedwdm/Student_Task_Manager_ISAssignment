import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Plus Jakarta Sans
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    letterSpacing: -1,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  // Inter
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: AppColors.onSurfaceVariant,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColors.outline,
    letterSpacing: 1.5,
  );
}
