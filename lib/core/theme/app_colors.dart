import 'package:flutter/material.dart';

/// Design tokens aligned with Figma / screenshots (dark theme).
abstract final class AppColors {
  static const Color scaffoldBg = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color card = Color(0xFF1A1A1A);
  static const Color inputFill = Color(0xFF2C2C2E);
  static const Color border = Color(0xFF3A3A3C);

  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryIndigo = Color(0xFF3F37C9);
  static const Color accentPurple = Color(0xFF4A47A3);
  static const Color logoBlue = Color(0xFF007AFF);

  static const Color incomeGreen = Color(0xFF22C55E);
  static const Color expenseRed = Color(0xFFEF4444);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF6B7280);

  static const LinearGradient incomeCardGradient = LinearGradient(
    colors: [Color(0xFF14532D), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseCardGradient = LinearGradient(
    colors: [Color(0xFF7F1D1D), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
