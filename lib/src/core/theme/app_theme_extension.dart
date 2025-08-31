import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  final Color headerGradientStart;
  final Color headerGradientEnd;
  final Color chipBg;
  final double cornerRadius;
  final EdgeInsets contentPadding;

  const AppThemeTokens({
    required this.headerGradientStart,
    required this.headerGradientEnd,
    required this.chipBg,
    required this.cornerRadius,
    required this.contentPadding,
  });

  factory AppThemeTokens.dark() => const AppThemeTokens(
        headerGradientStart: AppColors.primaryPurple,
        headerGradientEnd: AppColors.primaryTeal,
        chipBg: AppColors.bgDarkElevated,
        cornerRadius: 14,
        contentPadding: EdgeInsets.all(AppSpacing.md),
      );

  factory AppThemeTokens.light() => const AppThemeTokens(
        headerGradientStart: AppColors.primaryPurple,
        headerGradientEnd: AppColors.primaryTeal,
        chipBg: Colors.white,
        cornerRadius: 14,
        contentPadding: EdgeInsets.all(AppSpacing.md),
      );

  @override
  ThemeExtension<AppThemeTokens> copyWith({
    Color? headerGradientStart,
    Color? headerGradientEnd,
    Color? chipBg,
    double? cornerRadius,
    EdgeInsets? contentPadding,
  }) {
    return AppThemeTokens(
      headerGradientStart: headerGradientStart ?? this.headerGradientStart,
      headerGradientEnd: headerGradientEnd ?? this.headerGradientEnd,
      chipBg: chipBg ?? this.chipBg,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }

  @override
  ThemeExtension<AppThemeTokens> lerp(covariant ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      headerGradientStart: Color.lerp(headerGradientStart, other.headerGradientStart, t)!,
      headerGradientEnd: Color.lerp(headerGradientEnd, other.headerGradientEnd, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      cornerRadius: cornerRadius + (other.cornerRadius - cornerRadius) * t,
      contentPadding: EdgeInsets.lerp(contentPadding, other.contentPadding, t)!,
    );
  }
}
