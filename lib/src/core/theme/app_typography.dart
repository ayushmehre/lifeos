import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static TextTheme darkTextTheme = const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: Colors.white70),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, color: Colors.white60),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  ).apply(fontFamily: fontFamily);

  static TextTheme lightTextTheme = const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: Colors.black54),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, color: Colors.black45),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  ).apply(fontFamily: fontFamily);
}
