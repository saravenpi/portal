import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../core/ui/widgets/pixel_button.dart';
import '../../../../domain/models/link_item.dart';

class LinkRow extends StatefulWidget {
  const LinkRow({
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
  State<LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<LinkRow> {
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
      child: InkWell(
        onTap: _openUrl,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surfaceRaised : AppColors.surface,
            border: const Border(
              bottom: BorderSide(
                color: AppColors.rule,
                width: AppSpacing.hairline,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
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
                onPressed: widget.link.isFavorite
                    ? widget.onToggleFavorite
                    : widget.onToggleFavorite,
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                widget.link.isPrivate ? PixelIcons.lock : PixelIcons.link,
                size: 16,
                color: widget.link.isPrivate
                    ? AppColors.warning
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.link.name.isNotEmpty
                                ? widget.link.name
                                : widget.link.url,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.link.health != LinkHealth.unknown) ...<Widget>[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: widget.link.health == LinkHealth.healthy
                                  ? AppColors.success
                                  : AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          Text(
                            domain.toUpperCase(),
                            style: AppTypography.caption,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '// ${widget.categoryName.toUpperCase()}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          if (widget.link.tags.isNotEmpty) ...<Widget>[
                            const SizedBox(width: AppSpacing.sm),
                            for (final String tag in widget.link.tags.take(3)) ...<Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.xs),
                                child: InkWell(
                                  onTap: widget.onTagSelected != null
                                      ? () => widget.onTagSelected!(tag)
                                      : null,
                                  child: Text(
                                    '#${tag.toLowerCase()}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PopupMenuButton<String>(
                tooltip: 'ACTIONS',
                icon: const Icon(
                  PixelIcons.moreHorizontal,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                color: AppColors.surfaceRaised,
                onSelected: (String action) {
                  switch (action) {
                    case 'open':
                      _openUrl();
                      break;
                    case 'copy':
                      _copyUrl(context);
                      break;
                    case 'edit':
                      widget.onEdit();
                      break;
                    case 'delete':
                      widget.onDelete();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'open',
                    child: Text('OPEN IN BROWSER', style: AppTypography.caption),
                  ),
                  const PopupMenuItem<String>(
                    value: 'copy',
                    child: Text('COPY URL', style: AppTypography.caption),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('EDIT', style: AppTypography.caption),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(
                      'DELETE',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontFamily: AppTypography.family,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
