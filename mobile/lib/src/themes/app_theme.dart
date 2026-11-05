import 'package:flutter/material.dart';

class AppTheme {
  // Agricultural SaaS Palette
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color primaryGreen = forestGreen; // Backwards compatibility for demo_card
  static const Color vibrantGreen = Color(0xFF2E7D32);
  static const Color sageSurface = Color(0xFFE8F5E9);
  static const Color earthBrown = Color(0xFF5D4037);
  static const Color backgroundLight = Color(0xFFF6F8F5);
  static const Color cardSurface = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: forestGreen,
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: forestGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: forestGreen,
      secondary: vibrantGreen,
      surface: cardSurface,
      surfaceContainerHighest: sageSurface,
      error: Color(0xFFD32F2F),
    ),
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 0.8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: forestGreen,
        foregroundColor: Colors.white,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
      bodyMedium: TextStyle(fontSize: 13.5, color: Color(0xFF37474F), height: 1.4),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF546E7A)),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 20,
    ),
  );
}
