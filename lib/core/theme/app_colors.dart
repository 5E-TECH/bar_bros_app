import 'package:flutter/material.dart';

class AppColors {
  static const Color yellow = Color(0xFFFA8B01);
  static const Color primaryLight = Color(0xFFFAF9F7);
  static const Color primaryDark = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFF3F1ED);
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color containerLight = Color(0xFFFFFFFF);
  static const Color containerDark = Color(0xFF1A1A1A);
  static const Color gradient1 = Color(0xFFFA9E04);
  static const Color gradient2 = Color(0xFFFA8500);
}

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'inter',
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.primaryLight,
    cardColor: AppColors.containerLight,
    dividerColor: const Color(0xFFE8E5E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFAF9F7),
      foregroundColor: Color(0xFF2C2C2C),
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFAF9F7),
      selectedItemColor: AppColors.yellow,
      unselectedItemColor: Color(0xFF6B6B6B),
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'inter',
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.containerDark,
    dividerColor: const Color(0xFF2A2A2A),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: const Color(0xFFE8E8E8),
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundDark,
      selectedItemColor: AppColors.yellow,
      unselectedItemColor: Color(0xFF9A9A9A),
    ),
  );
}