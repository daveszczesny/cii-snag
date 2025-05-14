import 'package:cii/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryGreen,
  scaffoldBackgroundColor: AppColors.backgroundColor,
  cardColor: AppColors.cardColor,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryGreen,
    secondary: Colors.white,
    error: AppColors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.primaryGreen),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.teal,
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  colorScheme: const ColorScheme.dark(
    primary: Colors.teal,
    secondary: AppColors.ctaOrange,
    surface: Color(0xFF1E1E1E),
    error: AppColors.red,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
  ),
);