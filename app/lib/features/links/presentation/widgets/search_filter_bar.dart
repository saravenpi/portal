import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../core/ui/widgets/pixel_button.dart';
import '../../../../domain/models/category.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCategoryId,
    required this.categories,
    required this.onCategoryChanged,
    required this.selectedTag,
    required this.onTagChanged,
    required this.favoritesOnly,
    required this.onFavoritesOnlyChanged,
    required this.includePrivate,
    required this.onIncludePrivateChanged,
    required this.isCardView,
    required this.onDensityChanged,
    required this.onAddLink,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String? selectedCategoryId;
  final List<Category> categories;
  final ValueChanged<String?> onCategoryChanged;
  final String? selectedTag;
  final ValueChanged<String?> onTagChanged;
  final bool favoritesOnly;
  final ValueChanged<bool> onFavoritesOnlyChanged;
  final bool includePrivate;
  final ValueChanged<bool> onIncludePrivateChanged;
  final bool isCardView;
  final ValueChanged<bool> onDensityChanged;
  final VoidCallback onAddLink;

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(SearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _controller.text != widget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Category? selectedCategory = widget.selectedCategoryId == null
        ? null
        : widget.categories.cast<Category?>().firstWhere(
              (Category? c) => c?.id == widget.selectedCategoryId,
              orElse: () => null,
            );

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: AppSpacing.controlHeight,
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onSearchChanged,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'SEARCH LINKS, URLS, TAGS...',
                      prefixIcon: const Icon(
                        PixelIcons.search,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(PixelIcons.close, size: 16),
                              onPressed: () {
                                _controller.clear();
                                widget.onSearchChanged('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PixelIconButton(
                icon: widget.isCardView
                    ? PixelIcons.bulletlist
                    : PixelIcons.grid2x22,
                tooltip: widget.isCardView ? 'LIST VIEW' : 'GRID VIEW',
                onPressed: () => widget.onDensityChanged(!widget.isCardView),
              ),
              const SizedBox(width: AppSpacing.sm),
              PixelButton(
                label: 'ADD LINK',
                icon: PixelIcons.plus,
                variant: PixelButtonVariant.primary,
                onPressed: widget.onAddLink,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                PopupMenuButton<String?>(
                  tooltip: 'FILTER CATEGORY',
                  initialValue: widget.selectedCategoryId,
                  onSelected: widget.onCategoryChanged,
                  color: AppColors.surfaceRaised,
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String?>>[
                    const PopupMenuItem<String?>(
                      value: null,
                      child: Text('ALL CATEGORIES', style: AppTypography.caption),
                    ),
                    for (final Category cat in widget.categories)
                      PopupMenuItem<String?>(
                        value: cat.id,
                        child: Text(
                          cat.name.toUpperCase(),
                          style: AppTypography.caption,
                        ),
                      ),
                  ],
                  child: Container(
                    height: AppSpacing.controlHeight - 8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: selectedCategory != null
                          ? AppColors.surfaceRaised
                          : Colors.transparent,
                      border: Border.all(
                        color: selectedCategory != null
                            ? AppColors.textPrimary
                            : AppColors.rule,
                        width: AppSpacing.hairline,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          PixelIcons.folder,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          selectedCategory == null
                              ? 'ALL CATEGORIES'
                              : selectedCategory.name.toUpperCase(),
                          style: AppTypography.captionStrong,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          PixelIcons.chevronDown,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChipToggle(
                  label: 'FAVORITES',
                  icon: PixelIcons.heart,
                  active: widget.favoritesOnly,
                  activeColor: AppColors.accent,
                  onToggle: () =>
                      widget.onFavoritesOnlyChanged(!widget.favoritesOnly),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChipToggle(
                  label: 'PRIVATE',
                  icon: PixelIcons.lock,
                  active: widget.includePrivate,
                  activeColor: AppColors.warning,
                  onToggle: () =>
                      widget.onIncludePrivateChanged(!widget.includePrivate),
                ),
                if (widget.selectedTag != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    height: AppSpacing.controlHeight - 8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: AppSpacing.hairline,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          PixelIcons.label,
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'TAG: ${widget.selectedTag!.toUpperCase()}',
                          style: AppTypography.captionStrong,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        InkWell(
                          onTap: () => widget.onTagChanged(null),
                          child: const Icon(PixelIcons.close, size: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                if (selectedCategory != null ||
                    widget.selectedTag != null ||
                    widget.favoritesOnly ||
                    !widget.includePrivate ||
                    _controller.text.isNotEmpty) ...<Widget>[
                  const SizedBox(width: AppSpacing.sm),
                  PixelButton(
                    label: 'RESET',
                    variant: PixelButtonVariant.ghost,
                    onPressed: () {
                      _controller.clear();
                      widget.onSearchChanged('');
                      widget.onCategoryChanged(null);
                      widget.onTagChanged(null);
                      widget.onFavoritesOnlyChanged(false);
                      widget.onIncludePrivateChanged(true);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipToggle extends StatelessWidget {
  const _FilterChipToggle({
    required this.label,
    required this.icon,
    required this.active,
    required this.onToggle,
    this.activeColor,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onToggle;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final Color color = active
        ? (activeColor ?? AppColors.textPrimary)
        : AppColors.textSecondary;

    return InkWell(
      onTap: onToggle,
      child: Container(
        height: AppSpacing.controlHeight - 8,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.surfaceRaised : Colors.transparent,
          border: Border.all(
            color: active ? color : AppColors.rule,
            width: AppSpacing.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label.toUpperCase(),
              style: AppTypography.captionStrong.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
