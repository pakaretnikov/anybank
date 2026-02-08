import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0071E3),
          secondary: Color(0xFF0A84FF),
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFF5F5F7),
          onSurface: Color(0xFF111827),
          onBackground: Color(0xFF111827),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Color(0xFF111827),
        ),
        cardColor: const Color(0xFFFFFFFF),
        dividerColor: const Color(0xFFE5E7EB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0071E3)),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Color(0xFF111827),
          unselectedLabelColor: Color(0xFF6B7280),
          indicatorColor: Color(0xFF0071E3),
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
}

