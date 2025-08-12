import 'package:flutter/material.dart';

class AppColors {
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color darkGreen = Color(0xFF128C7E);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.whatsappGreen,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: EdgeInsets.all(8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkGreen,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.whatsappGreen,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: colorScheme.primary,
      indicatorColor: colorScheme.primary,
      unselectedLabelColor: Colors.grey.shade600,
    ),
  );
}


