import 'package:flutter/material.dart';

class AppTheme {
  static const Color pastelPink = Color(0xFFFFD9E8);
  static const Color softViolet = Color(0xFFE5D9FF);
  static const Color creamWhite = Color(0xFFFFF9F2);
  static const Color waterBlue = Color(0xFFAEDBFF);
  static const Color blossomRose = Color(0xFFF08CB4);
  static const Color mintFresh = Color(0xFF69C9A8);
  static const Color oceanBlue = Color(0xFF5FA8FF);
  static const Color sunsetCoral = Color(0xFFFF8A65);

  static Color accentFromKey(String key) {
    switch (key) {
      case 'mint':
        return mintFresh;
      case 'ocean':
        return oceanBlue;
      case 'coral':
        return sunsetCoral;
      case 'rose':
      default:
        return blossomRose;
    }
  }

  static ThemeData lightTheme({Color? seedColor}) {
    final accent = seedColor ?? blossomRose;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: creamWhite,
    );

    return base.copyWith(
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(bodyColor: const Color(0xFF4A3B4E)),
    );
  }
}
