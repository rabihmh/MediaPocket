import 'package:flutter/material.dart';

class AppColors {
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color accentPurple = Color(0xFF8E24AA);
  static const Color bgDark = Color(0xFF0D0D0D);
  static const Color bgLight = Color(0xFF1A1A1A);
}

LinearGradient accentGradient() => const LinearGradient(
      colors: [Color(0xFF25D366), Color(0xFFE1306C), Color(0xFF8E24AA)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accentPurple,
    brightness: Brightness.dark,
    surface: AppColors.bgLight,
    background: AppColors.bgDark,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardTheme(
      color: AppColors.bgLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF2F2F2F)),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.accentPurple,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF444444)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF444444)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accentPurple),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppColors.accentPurple,
    ),
  );
}


