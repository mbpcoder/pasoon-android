import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color surfaceTint = Color(0xFFF0FDFA);
  static const Color background = Color(0xFFF3F4F6);
  static const Color text = Color(0xFF111827);
  static const Color muted = Color(0xFF4B5563);
  static const Color border = Color(0xFFE5E7EB);
  static const Color holiday = Color(0xFFB91C1C);
  static const Color eventDot = Color(0xFFEA580C);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, surface: Colors.white);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
  );
}
