import 'package:flutter/material.dart';

const serenityTeal = Color(0xFF408B7D);
const serenityMint = Color(0xFFE6F6F3);
const serenityBlue = Color(0xFFEAF4FF);
const serenityWarm = Color(0xFFFFEFE3);

ThemeData serenityTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: serenityTeal,
    primary: serenityTeal,
    secondary: const Color(0xFF6C8FA7),
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Arial',
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFFAFCFB),
    textTheme: Typography.blackMountainView.apply(fontFamily: 'Arial'),
    primaryTextTheme: Typography.blackMountainView.apply(fontFamily: 'Arial'),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1F2E2B),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8E5)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD7E2DE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: serenityTeal, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: serenityTeal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
