import 'package:flutter/material.dart';

/// App constants for colors, spacing, and typography
class AppConstants {
  // Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color accent = Color(0xFF00B894);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color mutedBg = Color(0xFFFAF7FF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color error = Color(0xFFEF4444);

  // Dark theme colors
  static const Color darkPrimary = Color(0xFF8B7CF8);
  static const Color darkAccent = Color(0xFF00D4AA);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkMutedBg = Color(0xFF0F172A);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);

  // Spacing (8px baseline)
  static const double spacingXs = 8.0;
  static const double spacingSm = 16.0;
  static const double spacingMd = 24.0;
  static const double spacingLg = 32.0;
  static const double spacingXl = 48.0;

  // Border radius
  static const double borderRadius = 16.0; // 2xl
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusLg = 24.0;

  // Shadows
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  // Typography
  static const String fontFamily = 'Inter';

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shimmerDuration = Duration(milliseconds: 200);
}
