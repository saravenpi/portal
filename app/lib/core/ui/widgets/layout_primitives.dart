import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';

class Rule extends StatelessWidget {
  const Rule({super.key, this.color = AppColors.rule});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.hairline,
      child: ColoredBox(color: color),
    );
  }
}

class VerticalRule extends StatelessWidget {
  const VerticalRule({super.key, this.color = AppColors.rule});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.hairline,
      child: ColoredBox(color: color),
    );
  }
}
