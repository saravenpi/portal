import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const String family = 'UndefinedMedium';
  static const List<String> fallback = <String>['monospace'];

  static const TextStyle _base = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    color: AppColors.textPrimary,
  );

  static const TextStyle display = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 40,
    height: 1.1,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 24,
    height: 1.25,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 18,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 14,
    height: 1.3,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 14,
    height: 1.3,
    letterSpacing: 1.2,
  );

  static const TextStyle buttonCaption = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 1.2,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 2.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionStrong = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle numeral = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 24,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: display,
    displayMedium: display,
    displaySmall: headline,
    headlineLarge: headline,
    headlineMedium: headline,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: title,
    titleSmall: label,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: label,
    labelMedium: label,
    labelSmall: overline,
  );

  static TextStyle get base => _base;
}

extension SwissTextCase on String {
  String get labelCase => toUpperCase();
}
