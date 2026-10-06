import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData build() {
    const ColorScheme scheme = ColorScheme.dark(
      primary: AppColors.textPrimary,
      onPrimary: AppColors.background,
      secondary: AppColors.accent,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceRaised,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.rule,
      outlineVariant: AppColors.rule,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      fontFamily: AppTypography.family,
      fontFamilyFallback: AppTypography.fallback,
      textTheme: AppTypography.textTheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: AppColors.surfaceRaised,
      hoverColor: AppColors.surfaceRaised,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.label,
        toolbarTextStyle: AppTypography.label,
        shape: AppRadii.border,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.none,
          side: BorderSide(color: AppColors.rule, width: AppSpacing.hairline),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.none,
          side: BorderSide(color: AppColors.rule, width: AppSpacing.hairline),
        ),
        titleTextStyle: AppTypography.title,
        contentTextStyle: AppTypography.body,
        insetPadding: EdgeInsets.all(AppSpacing.md),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: AppRadii.border,
        showDragHandle: false,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: AppTypography.body,
        actionTextColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: AppRadii.border,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.none,
          side: BorderSide(color: AppColors.rule, width: AppSpacing.hairline),
        ),
        textStyle: AppTypography.body,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMuted,
        labelStyle: AppTypography.overline,
        helperStyle: AppTypography.caption,
        errorStyle: AppTypography.caption,
        border: _inputBorder(AppColors.rule),
        enabledBorder: _inputBorder(AppColors.rule),
        focusedBorder: _inputBorder(AppColors.textPrimary),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger),
        disabledBorder: _inputBorder(AppColors.rule),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.rule,
        thickness: AppSpacing.hairline,
        space: AppSpacing.hairline,
      ),
      dividerColor: AppColors.rule,
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.transparent,
        side: BorderSide(color: AppColors.rule, width: AppSpacing.hairline),
        shape: AppRadii.border,
        labelStyle: AppTypography.caption,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.rule, width: AppSpacing.hairline),
          borderRadius: AppRadii.none,
        ),
        textStyle: AppTypography.captionStrong,
        waitDuration: const Duration(milliseconds: 400),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll<Color>(AppColors.ruleStrong),
        trackColor: WidgetStatePropertyAll<Color>(AppColors.background),
        radius: AppRadii.radius,
        thickness: WidgetStatePropertyAll<double>(6),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        shape: AppRadii.border,
        titleTextStyle: AppTypography.body,
        subtitleTextStyle: AppTypography.bodyMuted,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.textPrimary,
        selectionColor: Color(0x33FFFFFF),
        selectionHandleColor: AppColors.textPrimary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: AppRadii.none,
        borderSide: BorderSide(color: color, width: AppSpacing.hairline),
      );
}
