import 'package:flutter/material.dart';

class AppTheme {
  // --- Цвета темной темы ---
  static const Color _bgDark = Color(0xFF0F1117);
  static const Color _surfaceDark = Color(0xFF1A1D27);
  static const Color _surfaceVariantDark = Color(0xFF242736);
  static const Color _accentDark = Color(0xFF4FC3F7);
  static const Color _accentDeepDark = Color(0xFF0288D1);
  static const Color _textPrimaryDark = Color(0xFFECEFF1);
  static const Color _textSecondaryDark = Color(0xFF90A4AE);
  static const Color _dividerDark = Color(0xFF2E3347);
  static const Color _errorDark = Color(0xFFEF5350);

  // --- Цвета светлой темы ---
  static const Color _bgLight = Color(0xFFF8F9FA);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceVariantLight = Color(0xFFE9ECEF);
  static const Color _accentLight = Color(0xFF0288D1);
  static const Color _accentDeepLight = Color(0xFF01579B);
  static const Color _textPrimaryLight = Color(0xFF263238);
  static const Color _textSecondaryLight = Color(0xFF607D8B);
  static const Color _dividerLight = Color(0xFFCFD8DC);
  static const Color _errorLight = Color(0xFFD32F2F);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bgDark,
      colorScheme: const ColorScheme.dark(
        primary: _accentDark,
        secondary: _accentDeepDark,
        surface: _surfaceDark,
        surfaceContainer: _surfaceVariantDark, // Имитация surfaceVariant
        error: _errorDark,
        onPrimary: Color(0xFF0D1117),
        onSurface: _textPrimaryDark,
        onSurfaceVariant: _textSecondaryDark,
        onError: _textPrimaryDark,
        outline: _dividerDark,
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
        headlineMedium: const TextStyle(
          color: _textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        titleMedium: const TextStyle(
          color: _textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        bodyMedium: const TextStyle(
          color: _textSecondaryDark,
          fontSize: 14,
        ),
        labelLarge: const TextStyle(
          color: _textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariantDark,
        labelStyle: const TextStyle(color: _textSecondaryDark, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accentDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorDark),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceVariantDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _dividerDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _dividerDark),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _dividerDark),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: _textSecondaryDark),
      ),
      dividerTheme: const DividerThemeData(
        color: _dividerDark,
        thickness: 1,
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _bgLight,
      colorScheme: const ColorScheme.light(
        primary: _accentLight,
        secondary: _accentDeepLight,
        surface: _surfaceLight,
        surfaceContainer: _surfaceVariantLight,
        error: _errorLight,
        onPrimary: Colors.white,
        onSurface: _textPrimaryLight,
        onSurfaceVariant: _textSecondaryLight,
        onError: Colors.white,
        outline: _dividerLight,
      ),
      textTheme: ThemeData.light().textTheme.copyWith(
        headlineMedium: const TextStyle(
          color: _textPrimaryLight,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        titleMedium: const TextStyle(
          color: _textPrimaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        bodyMedium: const TextStyle(
          color: _textSecondaryLight,
          fontSize: 14,
        ),
        labelLarge: const TextStyle(
          color: _textPrimaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariantLight,
        labelStyle: const TextStyle(color: _textSecondaryLight, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accentLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorLight),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceVariantLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _dividerLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _dividerLight),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _dividerLight),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _bgLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _textPrimaryLight,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: _textSecondaryLight),
      ),
      dividerTheme: const DividerThemeData(
        color: _dividerLight,
        thickness: 1,
      ),
    );
  }
}
