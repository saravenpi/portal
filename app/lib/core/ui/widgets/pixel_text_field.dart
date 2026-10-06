import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';

class PixelTextField extends StatelessWidget {
  const PixelTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool autofocus;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          label: label,
          child: Text(label.toUpperCase(), style: AppTypography.overline),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          autofocus: autofocus,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: AppTypography.body,
          cursorColor: AppTypography.body.color,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
          ),
        ),
        if (helperText != null && errorText == null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(helperText!, style: AppTypography.caption),
        ],
      ],
    );
  }
}
