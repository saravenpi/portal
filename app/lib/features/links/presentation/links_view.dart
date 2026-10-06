import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../core/ui/widgets/app_dialog.dart';
import '../../../../core/ui/widgets/pixel_button.dart';
import '../../../../domain/models/category.dart';
import 'links_view_model.dart';
import 'widgets/link_card.dart';
import 'widgets/link_editor_dialog.dart';
import 'widgets/link_row.dart';
import 'widgets/search_filter_bar.dart';

class LinksView extends StatelessWidget {
  const LinksView({super.key});

  Future<void> _openAddLink(BuildContext context, LinksViewModel vm) async {
    final LinkEditorResult? result = await LinkEditorDialog.show(
      context: context,
      categories: vm.categories,
      initialCategoryId: vm.filter.categoryId,
    );
    if (result != null) {
      await vm.addLink(
        categoryId: result.categoryId,
        link: result.link,
      );
    }
  }

  Future<void> _openEditLink(
    BuildContext context,
    LinksViewModel vm,
    CategorizedLink item,
  ) async {
    final LinkEditorResult? result = await LinkEditorDialog.show(
      context: context,
      categories: vm.categories,
      initialLink: item.link,
      initialCategoryId: item.categoryId,
    );
    if (result != null) {
      if (result.categoryId != item.categoryId) {
        await vm.deleteLink(categoryId: item.categoryId, linkId: item.link.id);
        await vm.addLink(categoryId: result.categoryId, link: result.link);
      } else {
        await vm.updateLink(categoryId: result.categoryId, link: result.link);
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LinksViewModel vm,
    CategorizedLink item,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AppDialog(
        title: 'DELETE LINK',
        content: Text(
          'ARE YOU SURE YOU WANT TO DELETE "${item.link.name.toUpperCase()}"?',
          style: AppTypography.body,
        ),
        actions: <Widget>[
          PixelButton(
            label: 'CANCEL',
            variant: PixelButtonVariant.ghost,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          PixelButton(
            label: 'DELETE',
            variant: PixelButtonVariant.danger,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vm.deleteLink(
        categoryId: item.categoryId,
        linkId: item.link.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LinksViewModel vm = context.watch<LinksViewModel>();
    final List<CategorizedLink> links = vm.filteredLinks;
    final int total = vm.totalCount;
    final int filtered = vm.filteredCount;

    final String countLabel = filtered == total
        ? '$total ${total == 1 ? 'LINK' : 'LINKS'}'
        : '$filtered OF $total LINKS';

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SearchFilterBar(
            searchQuery: vm.filter.searchQuery,
            onSearchChanged: vm.setSearchQuery,
            selectedCategoryId: vm.filter.categoryId,
            categories: vm.categories,
            onCategoryChanged: vm.setCategory,
            selectedTag: vm.filter.selectedTag,
            onTagChanged: vm.setSelectedTag,
            favoritesOnly: vm.filter.favoritesOnly,
            onFavoritesOnlyChanged: vm.setFavoritesOnly,
            includePrivate: vm.filter.includePrivate,
            onIncludePrivateChanged: vm.setIncludePrivate,
            isCardView: vm.isCardView,
            onDensityChanged: vm.setDensity,
            onAddLink: () => _openAddLink(context, vm),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.rule,
                  width: AppSpacing.hairline,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  countLabel,
                  style: AppTypography.captionStrong,
                ),
                const Spacer(),
                if (vm.filter.categoryId != null) ...<Widget>[
                  Text(
                    'CATEGORY: ${_getCategoryName(vm.categories, vm.filter.categoryId!).toUpperCase()}',
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: links.isEmpty
                ? _EmptyState(
                    hasQuery: vm.filter.searchQuery.isNotEmpty ||
                        vm.filter.categoryId != null ||
                        vm.filter.selectedTag != null ||
                        vm.filter.favoritesOnly,
                    onReset: vm.clearFilters,
                    onAddLink: () => _openAddLink(context, vm),
                  )
                : vm.isCardView
                    ? _CardGrid(
                        links: links,
                        onToggleFavorite: (CategorizedLink item) =>
                            vm.toggleFavorite(
                          categoryId: item.categoryId,
                          linkId: item.link.id,
                        ),
                        onEdit: (CategorizedLink item) =>
                            _openEditLink(context, vm, item),
                        onDelete: (CategorizedLink item) =>
                            _confirmDelete(context, vm, item),
                        onTagSelected: vm.setSelectedTag,
                      )
                    : ListView.builder(
                        itemCount: links.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CategorizedLink item = links[index];
                          return LinkRow(
                            key: ValueKey<String>(item.link.id),
                            link: item.link,
                            categoryName: item.categoryName,
                            onToggleFavorite: () => vm.toggleFavorite(
                              categoryId: item.categoryId,
                              linkId: item.link.id,
                            ),
                            onEdit: () => _openEditLink(context, vm, item),
                            onDelete: () => _confirmDelete(context, vm, item),
                            onTagSelected: vm.setSelectedTag,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(List<Category> categories, String id) {
    for (final Category cat in categories) {
      if (cat.id == id) return cat.name;
    }
    return id;
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({
    required this.links,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.onTagSelected,
  });

  final List<CategorizedLink> links;
  final ValueChanged<CategorizedLink> onToggleFavorite;
  final ValueChanged<CategorizedLink> onEdit;
  final ValueChanged<CategorizedLink> onDelete;
  final ValueChanged<String> onTagSelected;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final int crossAxisCount = width >= 1400
        ? 3
        : width >= 900
            ? 2
            : 1;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        mainAxisExtent: 220,
      ),
      itemCount: links.length,
      itemBuilder: (BuildContext context, int index) {
        final CategorizedLink item = links[index];
        return LinkCard(
          key: ValueKey<String>(item.link.id),
          link: item.link,
          categoryName: item.categoryName,
          onToggleFavorite: () => onToggleFavorite(item),
          onEdit: () => onEdit(item),
          onDelete: () => onDelete(item),
          onTagSelected: onTagSelected,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasQuery,
    required this.onReset,
    required this.onAddLink,
  });

  final bool hasQuery;
  final VoidCallback onReset;
  final VoidCallback onAddLink;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              PixelIcons.unlink,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasQuery ? 'NO MATCHING LINKS' : 'VAULT IS EMPTY',
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hasQuery
                  ? 'TRY CLEARING YOUR SEARCH OR ACTIVE FILTERS.'
                  : 'ADD YOUR FIRST BOOKMARK OR IMPORT FROM YAML.',
              style: AppTypography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (hasQuery)
              PixelButton(
                label: 'RESET FILTERS',
                variant: PixelButtonVariant.secondary,
                onPressed: onReset,
              )
            else
              PixelButton(
                label: 'ADD FIRST LINK',
                icon: PixelIcons.plus,
                variant: PixelButtonVariant.primary,
                onPressed: onAddLink,
              ),
          ],
        ),
      ),
    );
  }
}
