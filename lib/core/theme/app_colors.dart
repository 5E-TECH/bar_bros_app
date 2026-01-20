import 'package:flutter/material.dart';

class AppColors {
  static const Color yellow = Color(0xFFFA8B01);
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF0B0C17);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF1B1D2E);
  static const Color containerLight = Color(0xFFFFFFFF);
  static const Color containerDark = Color(0xFF2A2D3E);
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
    appBarTheme:  AppBarTheme(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark, scrolledUnderElevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.yellow,
      unselectedItemColor: Colors.black,
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'inter',
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.containerDark,
    appBarTheme:  AppBarTheme(backgroundColor: AppColors.backgroundDark, foregroundColor: AppColors.primaryLight, scrolledUnderElevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundDark,
      selectedItemColor: AppColors.yellow,
      unselectedItemColor: Colors.white,
    ),
  );
}