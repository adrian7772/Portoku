import 'package:flutter/material.dart';

class AppTheme {
  // Core colors
  static const Color navy = Color(0xFF0A1A2F);
  static const Color surface = Color(0xFF0F2A54);
  static const Color accent = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFF7DD3FC);

  static const Color text = Color(0xFFEAF2FF);
  static const Color subText = Color(0xFFBBD6FF);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: surface,
    );

    return base.copyWith(
      colorScheme: scheme.copyWith(
        primary: accent,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: text,
      ),
      scaffoldBackgroundColor: navy,

      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navy,
        indicatorColor: accent.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? Colors.white : subText,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? Colors.white : subText,
          ),
        ),
      ),

cardTheme: CardThemeData(
  color: surface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
    side: const BorderSide(color: Colors.white12),
  ),
),


      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        textColor: text,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: subText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.2),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: const TextStyle(color: text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
