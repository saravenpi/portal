import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/ui/pixel_icons.dart';

class FaviconBadge extends StatelessWidget {
  const FaviconBadge({
    super.key,
    required this.url,
    this.faviconUrl,
    this.size = 20,
  });

  final String url;
  final String? faviconUrl;
  final double size;

  String? _resolveFavicon() {
    if (faviconUrl != null && faviconUrl!.trim().isNotEmpty) {
      return faviconUrl!.trim();
    }
    final Uri? uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return '${uri.scheme}://${uri.host}/favicon.ico';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String? resolved = _resolveFavicon();
    if (resolved == null || resolved.isEmpty) {
      return _buildFallback();
    }

    final double innerSize = size - 4;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.rule,
          width: AppSpacing.hairline,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxs),
      child: Image.network(
        resolved,
        width: innerSize,
        height: innerSize,
        fit: BoxFit.contain,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return _buildFallbackIcon();
        },
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(
          color: AppColors.rule,
          width: AppSpacing.hairline,
        ),
      ),
      child: _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      PixelIcons.link,
      size: size * 0.65,
      color: AppColors.textSecondary,
    );
  }
}
