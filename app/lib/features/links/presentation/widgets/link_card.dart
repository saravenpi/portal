import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../core/ui/widgets/layout_primitives.dart';
import '../../../../core/ui/widgets/pixel_button.dart';
import '../../../../domain/models/link_item.dart';

class LinkCard extends StatefulWidget {
  const LinkCard({
    super.key,
    required this.link,
    required this.categoryName,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    this.onTagSelected,
  });

  final LinkItem link;
  final String categoryName;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String>? onTagSelected;

  @override
  State<LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<LinkCard> {
  bool _hovered = false;

  Future<void> _openUrl() async {
    final Uri? uri = Uri.tryParse(widget.link.url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }
    }
  }

  void _copyUrl(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.link.url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL COPIED TO CLIPBOARD', style: AppTypography.captionStrong),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _extractDomain(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.host.replaceFirst(RegExp(r'^www\.'), '');
  }

  @override
  Widget build(BuildContext context) {
    final String domain = _extractDomain(widget.link.url);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hovered ? AppColors.surfaceRaised : AppColors.surface,
          border: Border.all(
            color: _hovered ? AppColors.ruleStrong : AppColors.rule,
            width: AppSpacing.hairline,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  widget.link.isPrivate ? PixelIcons.lock : PixelIcons.link,
                  size: 18,
                  color: widget.link.isPrivate
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.link.name.isNotEmpty
                        ? widget.link.name
                        : widget.link.url,
                    style: AppTypography.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.link.health != LinkHealth.unknown) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.link.health == LinkHealth.healthy
                          ? AppColors.success
                          : AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                const SizedBox(width: AppSpacing.xs),
                PixelIconButton(
                  icon: widget.link.isFavorite
                      ? PixelIcons.heart
                      : PixelIcons.heart,
                  color: widget.link.isFavorite
                      ? AppColors.accent
                      : AppColors.textTertiary,
                  size: 32,
                  tooltip: widget.link.isFavorite
                      ? 'REMOVE FAVORITE'
                      : 'FAVORITE',
                  onPressed: widget.onToggleFavorite,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    domain.toUpperCase(),
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    '// ${widget.categoryName.toUpperCase()}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (widget.link.description != null &&
                widget.link.description!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.link.description!,
                style: AppTypography.bodyMuted,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (widget.link.tags.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  for (final String tag in widget.link.tags)
                    InkWell(
                      onTap: widget.onTagSelected != null
                          ? () => widget.onTagSelected!(tag)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.rule,
                            width: AppSpacing.hairline,
                          ),
                        ),
                        child: Text(
                          '#${tag.toLowerCase()}',
                          style: AppTypography.caption,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const Spacer(),
            const SizedBox(height: AppSpacing.md),
            const Rule(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: PixelButton(
                    label: 'OPEN',
                    icon: PixelIcons.externalLink,
                    variant: PixelButtonVariant.secondary,
                    onPressed: _openUrl,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PixelIconButton(
                  icon: PixelIcons.copy,
                  tooltip: 'COPY URL',
                  onPressed: () => _copyUrl(context),
                  size: AppSpacing.controlHeight,
                ),
                const SizedBox(width: AppSpacing.xs),
                PixelIconButton(
                  icon: PixelIcons.pencil,
                  tooltip: 'EDIT',
                  onPressed: widget.onEdit,
                  size: AppSpacing.controlHeight,
                ),
                const SizedBox(width: AppSpacing.xs),
                PixelIconButton(
                  icon: PixelIcons.trash,
                  color: AppColors.accent,
                  tooltip: 'DELETE',
                  onPressed: widget.onDelete,
                  size: AppSpacing.controlHeight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
