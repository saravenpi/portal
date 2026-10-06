import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../core/ui/widgets/layout_primitives.dart';
import '../../../../data/storage/portal_vault.dart';
import '../../categories/presentation/categories_view.dart';
import '../../links/presentation/links_view.dart';
import '../../links/presentation/links_view_model.dart';
import '../../links/presentation/widgets/link_editor_dialog.dart';
import '../../settings/presentation/settings_view.dart';
import '../../tags/presentation/tags_view.dart';

class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const List<AppDestination> _destinations = <AppDestination>[
    AppDestination(label: 'Links', icon: PixelIcons.bookmark),
    AppDestination(label: 'Categories', icon: PixelIcons.folder),
    AppDestination(label: 'Tags', icon: PixelIcons.label),
    AppDestination(label: 'Settings', icon: PixelIcons.sliders),
  ];

  int _selected = 0;

  void _select(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
  }

  void _onCategorySelected(String categoryId) {
    final LinksViewModel vm = context.read<LinksViewModel>();
    vm.setCategory(categoryId);
    setState(() => _selected = 0);
  }

  void _onTagSelected(String tag) {
    final LinksViewModel vm = context.read<LinksViewModel>();
    vm.setSelectedTag(tag);
    setState(() => _selected = 0);
  }

  Future<void> _handleNewLinkKey() async {
    final LinksViewModel vm = context.read<LinksViewModel>();
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

  @override
  Widget build(BuildContext context) {
    final bool wide =
        MediaQuery.sizeOf(context).width >= AppLayout.breakpointSidebar;
    final PortalVault vault = context.watch<PortalVault>();
    final int linksCount = vault.allLinks.length;
    final int categoriesCount = vault.categories.length;
    final int tagsCount = vault.allDistinctTags.length;

    final String activeFileName =
        vault.activeFilePath.split(Platform.pathSeparator).last;

    final Widget content = IndexedStack(
      index: _selected,
      children: <Widget>[
        const LinksView(),
        CategoriesView(onSelectCategory: _onCategorySelected),
        TagsView(onSelectTag: _onTagSelected),
        const SettingsView(),
      ],
    );

    final Widget scaffold = wide
        ? Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Sidebar(
                  destinations: _destinations,
                  selected: _selected,
                  onSelect: _select,
                  linksCount: linksCount,
                  categoriesCount: categoriesCount,
                  tagsCount: tagsCount,
                  activeFileName: activeFileName,
                  isWatching: vault.isWatching,
                ),
                const VerticalRule(),
                Expanded(child: content),
              ],
            ),
          )
        : Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(child: content),
                const Rule(),
                _BottomBar(
                  destinations: _destinations,
                  selected: _selected,
                  onSelect: _select,
                ),
              ],
            ),
          );

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN): _handleNewLinkKey,
        const SingleActivator(LogicalKeyboardKey.digit1): () => _select(0),
        const SingleActivator(LogicalKeyboardKey.digit2): () => _select(1),
        const SingleActivator(LogicalKeyboardKey.digit3): () => _select(2),
        const SingleActivator(LogicalKeyboardKey.digit4): () => _select(3),
      },
      child: Focus(
        autofocus: true,
        child: scaffold,
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.destinations,
    required this.selected,
    required this.onSelect,
    required this.linksCount,
    required this.categoriesCount,
    required this.tagsCount,
    required this.activeFileName,
    required this.isWatching,
  });

  final List<AppDestination> destinations;
  final int selected;
  final ValueChanged<int> onSelect;
  final int linksCount;
  final int categoriesCount;
  final int tagsCount;
  final String activeFileName;
  final bool isWatching;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppLayout.sidebarWidth,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: _Wordmark(),
            ),
            const Rule(),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < destinations.length; i++)
              _NavItem(
                destination: destinations[i],
                selected: i == selected,
                onTap: () => onSelect(i),
                badge: i == 0
                    ? linksCount
                    : i == 1
                        ? categoriesCount
                        : i == 2
                            ? tagsCount
                            : 0,
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.rule,
                    width: AppSpacing.hairline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isWatching
                                ? AppColors.success
                                : AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          isWatching ? 'SYNC ACTIVE' : 'LOCAL',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      activeFileName.toUpperCase(),
                      style: AppTypography.captionStrong,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          PixelIcons.externalLink,
          size: 24,
          color: AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'PORTAL',
            style: AppTypography.title.copyWith(letterSpacing: 3),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.badge,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(AppRadii.border),
          elevation: const WidgetStatePropertyAll<double>(0),
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(double.infinity, AppSpacing.controlHeightLarge),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (selected) return AppColors.surfaceRaised;
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)) {
                return AppColors.surface;
              }
              return Colors.transparent;
            },
          ),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 2,
              height: AppSpacing.controlHeightLarge,
              child: ColoredBox(
                color: selected ? AppColors.textPrimary : Colors.transparent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              destination.icon,
              size: 18,
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                destination.label.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected ? AppColors.textPrimary : AppColors.rule,
                    width: AppSpacing.hairline,
                  ),
                ),
                child: Text(
                  '$badge',
                  style: AppTypography.captionStrong,
                ),
              ),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.destinations,
    required this.selected,
    required this.onSelect,
  });

  final List<AppDestination> destinations;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppSpacing.controlHeightLarge + AppSpacing.sm,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < destinations.length; i++)
              Expanded(
                child: _BottomBarItem(
                  destination: destinations[i],
                  selected: i == selected,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(AppRadii.border),
          elevation: const WidgetStatePropertyAll<double>(0),
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)) {
                return AppColors.surface;
              }
              return Colors.transparent;
            },
          ),
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 2,
                width: 32,
                child: ColoredBox(
                  color: selected ? AppColors.textPrimary : Colors.transparent,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    destination.icon,
                    size: 20,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    destination.label.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
