import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';
import 'layout_primitives.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const <Widget>[],
    this.width = 480,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                title.toUpperCase(),
                style: AppTypography.title.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: AppSpacing.md),
              const Rule(),
              const SizedBox(height: AppSpacing.md),
              Flexible(child: SingleChildScrollView(child: content)),
              if (actions.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    for (int i = 0; i < actions.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
