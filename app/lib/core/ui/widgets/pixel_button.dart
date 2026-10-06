import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';

enum PixelButtonVariant { primary, secondary, ghost, danger }

class PixelButton extends StatelessWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = PixelButtonVariant.secondary,
    this.trailingIcon,
    this.expand = false,
    this.large = false,
    this.tooltip,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final PixelButtonVariant variant;
  final bool expand;
  final bool large;
  final String? tooltip;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final _ButtonPalette palette = _ButtonPalette.of(variant);

    final ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(expand ? double.infinity : 0, large ? AppSpacing.controlHeightLarge : AppSpacing.controlHeight),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(AppRadii.border),
      elevation: const WidgetStatePropertyAll<double>(0),
      textStyle: const WidgetStatePropertyAll<TextStyle>(AppTypography.buttonLabel),
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) return palette.disabledFill;
        if (states.contains(WidgetState.pressed)) return palette.pressedFill;
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return palette.hoverFill;
        }
        return palette.fill;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) return AppColors.textTertiary;
        return palette.foreground;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide?>((Set<WidgetState> states) {
        if (palette.border == null) return null;
        final Color color = states.contains(WidgetState.disabled)
            ? AppColors.rule
            : (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused))
                ? AppColors.ruleStrong
                : palette.border!;
        return BorderSide(color: color, width: AppSpacing.hairline);
      }),
    );

    final Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 16),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: AppTypography.buttonLabel,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingIcon != null) ...<Widget>[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: 16),
        ],
      ],
    );

    final Widget button = TextButton(
      onPressed: onPressed,
      style: style,
      autofocus: autofocus,
      child: content,
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class PixelIconButton extends StatelessWidget {
  const PixelIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.size = AppSpacing.minTapTarget,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll<Size>(Size.square(size)),
          maximumSize: WidgetStatePropertyAll<Size>(Size.square(size)),
          padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(AppRadii.border),
          elevation: const WidgetStatePropertyAll<double>(0),
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
              return AppColors.surfaceRaised;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) return AppColors.textTertiary;
            return color ?? AppColors.textPrimary;
          }),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _ButtonPalette {
  const _ButtonPalette({
    required this.fill,
    required this.hoverFill,
    required this.pressedFill,
    required this.disabledFill,
    required this.foreground,
    this.border,
  });

  factory _ButtonPalette.of(PixelButtonVariant variant) {
    switch (variant) {
      case PixelButtonVariant.primary:
        return const _ButtonPalette(
          fill: AppColors.textPrimary,
          hoverFill: Color(0xFFE0E0E0),
          pressedFill: Color(0xFFBFBFBF),
          disabledFill: Color(0xFF2A2A2A),
          foreground: AppColors.background,
        );
      case PixelButtonVariant.secondary:
        return const _ButtonPalette(
          fill: Colors.transparent,
          hoverFill: AppColors.surfaceRaised,
          pressedFill: Color(0xFF262626),
          disabledFill: Colors.transparent,
          foreground: AppColors.textPrimary,
          border: AppColors.rule,
        );
      case PixelButtonVariant.ghost:
        return const _ButtonPalette(
          fill: Colors.transparent,
          hoverFill: AppColors.surfaceRaised,
          pressedFill: Color(0xFF262626),
          disabledFill: Colors.transparent,
          foreground: AppColors.textSecondary,
        );
      case PixelButtonVariant.danger:
        return const _ButtonPalette(
          fill: Colors.transparent,
          hoverFill: Color(0xFF2A0E0E),
          pressedFill: Color(0xFF3D1414),
          disabledFill: Colors.transparent,
          foreground: AppColors.accent,
          border: AppColors.accent,
        );
    }
  }

  final Color fill;
  final Color hoverFill;
  final Color pressedFill;
  final Color disabledFill;
  final Color foreground;
  final Color? border;
}
