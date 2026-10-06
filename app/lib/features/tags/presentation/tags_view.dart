import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../data/storage/portal_vault.dart';
import '../../../../domain/models/link_item.dart';

class TagsView extends StatelessWidget {
  const TagsView({
    super.key,
    this.onSelectTag,
  });

  final ValueChanged<String>? onSelectTag;

  Map<String, int> _computeTagCounts(List<LinkItem> links) {
    final Map<String, int> counts = <String, int>{};
    for (final LinkItem link in links) {
      for (final String tag in link.tags) {
        final String normalized = tag.toLowerCase().trim();
        if (normalized.isNotEmpty) {
          counts[normalized] = (counts[normalized] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final PortalVault vault = context.watch<PortalVault>();
    final List<LinkItem> links = vault.allLinks;
    final Map<String, int> tagCounts = _computeTagCounts(links);
    final List<String> sortedTags = tagCounts.keys.toList()..sort();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.rule,
                  width: AppSpacing.hairline,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  PixelIcons.label,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${sortedTags.length} ${sortedTags.length == 1 ? 'TAG' : 'TAGS'}',
                  style: AppTypography.title,
                ),
              ],
            ),
          ),
          Expanded(
            child: sortedTags.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          PixelIcons.label,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'NO TAGS RECORDED',
                          style: AppTypography.title,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'TAG YOUR LINKS IN THE EDITOR TO BUILD A TAXONOMY.',
                          style: AppTypography.bodyMuted,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 240,
                        mainAxisExtent: 56,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                      ),
                      itemCount: sortedTags.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String tag = sortedTags[index];
                        final int count = tagCounts[tag] ?? 0;

                        return _TagTile(
                          tag: tag,
                          count: count,
                          onTap: onSelectTag != null
                              ? () => onSelectTag!(tag)
                              : null,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TagTile extends StatefulWidget {
  const _TagTile({
    required this.tag,
    required this.count,
    this.onTap,
  });

  final String tag;
  final int count;
  final VoidCallback? onTap;

  @override
  State<_TagTile> createState() => _TagTileState();
}

class _TagTileState extends State<_TagTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surfaceRaised : AppColors.surface,
            border: Border.all(
              color: _hovered ? AppColors.textPrimary : AppColors.rule,
              width: AppSpacing.hairline,
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                PixelIcons.label,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '#${widget.tag.toLowerCase()}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.rule,
                    width: AppSpacing.hairline,
                  ),
                ),
                child: Text(
                  '${widget.count}',
                  style: AppTypography.captionStrong,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
