import 'package:flutter/material.dart';

/// Slack-inspired color tokens. Do not use directly in widgets; pull via Theme.
class AppColors {
  AppColors._();

  // Primaries
  static const Color primaryPurple = Color(0xFF611F69);
  static const Color primaryTeal = Color(0xFF36C5F0);
  static const Color primaryGreen = Color(0xFF2EB67D);

  // Backgrounds
  static const Color bgDark = Color(0xFF1A1D21);
  static const Color bgDarkElevated = Color(0xFF222529);
  static const Color bgLight = Color(0xFFFFFFFF);

  // Surfaces / Borders
  static const Color surfaceDark = Color(0xFF222529);
  static const Color borderDark = Color(0xFF3D4043);

  // Text
  static const Color textPrimaryDark = Color(0xFFEDEDED);
  static const Color textSecondaryDark = Color(0xFF9AA1A9);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}
