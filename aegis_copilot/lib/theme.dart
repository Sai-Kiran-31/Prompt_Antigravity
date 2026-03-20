import 'package:flutter/material.dart';

class AegisTheme {
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color surfaceGrey = Color(0xFF1C1C1E);
  static const Color accentNeon = Color(0xFF00FFBC);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    primaryColor: primaryRed,
    colorScheme: ColorScheme.dark(
      primary: primaryRed,
      secondary: accentNeon,
      surface: surfaceGrey,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -1.0,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white70,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
