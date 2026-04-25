import 'package:flutter/material.dart';

/// Central color constants for the EnrollHub design system.
class AppColors {
  AppColors._();

  // Core backgrounds
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF222240);

  // Accents
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color secondary = Color(0xFF00D9FF);

  // Semantic
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFFF5252);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8EA0);

  // Structure
  static const Color divider = Color(0xFF2A2A3E);
  static const Color cardBorder = Color(0x0DFFFFFF); // white 5%

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Returns a unique gradient for student avatars based on index.
  static LinearGradient avatarGradient(int index) {
    final gradients = [
      const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)]),
      const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFFB74D)]),
      const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00D9FF)]),
      const LinearGradient(colors: [Color(0xFFFF5252), Color(0xFF6C63FF)]),
      const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF6B6B)]),
      const LinearGradient(colors: [Color(0xFF00D9FF), Color(0xFF6C63FF)]),
      const LinearGradient(colors: [Color(0xFF8B83FF), Color(0xFFFF6B6B)]),
      const LinearGradient(colors: [Color(0xFF00E676), Color(0xFFFFB74D)]),
    ];
    return gradients[index % gradients.length];
  }
}
