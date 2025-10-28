import 'package:flutter/material.dart';

class AppTheme {
  static const Color purple900 = Color(0xFF2E00A7);
  static const Color purple800 = Color(0xFF6412C6);
  static const Color zinc100 = Color(0xFFF8F8F8);
  static const Color zinc200 = Color(0xFFF4F4F4);
  static const Color zinc300 = Color(0xFFEDEDED);
  static const Color zinc400 = Color(0xFFE2E2E2);
  static const Color zinc500 = Color(0xFFB4B4B4);
  static const Color zinc600 = Color(0xFF909090);
  static const Color zinc700 = Color(0xFF727272);
  static const Color zinc800 = Color(0xFF5F5F60);
  static const Color green100 = Color(0xFFE5F7E8);
  static const Color green900 = Color(0xFF06df73);
  static const Color red100 = Color(0xFFF9E5E5);
  static const Color red900 = Color(0xFFCB0200);
  static const Color black800 = Color(0xFF161618);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color backgroundLight = Color(0xFFFCFCFC);
  static const Color backgroundDark = Color(0xFF161618);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF161618);
  static const Color white = Color(0xFFFFFFFF);
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Urbanist',
    colorScheme: const ColorScheme.light(
      primary: purple900,
      secondary: secondary,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: const TextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black,
    ),
    iconTheme: const IconThemeData(size: 22),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: purple900,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Urbanist',
    colorScheme: const ColorScheme.dark(
      primary: purple900,
      secondary: secondary,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: const TextTheme(),
    iconTheme: const IconThemeData(size: 22),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: purple900,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );
}
