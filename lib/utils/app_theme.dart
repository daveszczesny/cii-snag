
import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/utils/colors/status_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
      useMaterial3: true,
      primaryColor: AppColors.primaryBlue,
      secondaryHeaderColor: AppColors.ctaOrange,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      extensions: <ThemeExtension<dynamic>>[
        StatusColors(
          todo: AppColors.lightTodo,
          inProgress: AppColors.lightInProgress,
          completed: AppColors.lightCompleted,
          blocked: AppColors.lightBlocked
        )
      ]
    );
  }
}