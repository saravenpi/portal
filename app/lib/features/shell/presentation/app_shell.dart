import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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
  late final PageController _pageController;
  StreamSubscription<List<SharedMediaFile>>? _intentSub;
  bool _handlingIntent = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selected);
    _initSharingIntent();
  }

  void _initSharingIntent() {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      _handleSharedMedia,
      onError: (Object err) {},
    );

    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedMedia(value);
        ReceiveSharingIntent.instance.reset();
      }
    }).catchError((Object _) {});
  }

  void _handleSharedMedia(List<SharedMediaFile> files) {
    if (files.isEmpty || _handlingIntent) return;
    final String raw = files.first.path.trim();
    if (raw.isEmpty) return;

    final RegExp urlRegex = RegExp(r'https?://[^\s]+');
    final Match? match = urlRegex.firstMatch(raw);
    final String targetUrl = match != null ? match.group(0)! : raw;

    _handlingIntent = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _handlingIntent = false;
        return;
      }
      _select(0);
      final LinksViewModel vm = context.read<LinksViewModel>();
      final LinkEditorResult? result = await LinkEditorDialog.show(
        context: context,
        categories: vm.categories,
        initialCategoryId: vm.filter.categoryId,
        initialUrl: targetUrl,
      );
      if (result != null) {
        await vm.addLink(
          categoryId: result.categoryId,
          link: result.link,
        );
      }
      _handlingIntent = false;
    });
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
    if (_pageController.hasClients) {
      final bool wide =
          MediaQuery.sizeOf(context).width >= AppLayout.breakpointSidebar;
      if (wide) {
        _pageController.jumpToPage(index);
      } else {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _buildSection(int index) {
    switch (index) {
      case 0:
        return const LinksView();
      case 1:
        return CategoriesView(onSelectCategory: _onCategorySelected);
      case 2:
        return TagsView(onSelectTag: _onTagSelected);
      case 3:
        return const SettingsView();
      default:
        return const LinksView();
    }
  }

  void _onCategorySelected(String categoryId) {
    final LinksViewModel vm = context.read<LinksViewModel>();
    vm.setCategory(categoryId);
    _select(0);
  }

  void _onTagSelected(String tag) {
    final LinksViewModel vm = context.read<LinksViewModel>();
    vm.setSelectedTag(tag);
    _select(0);
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

    final Widget desktopContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey<int>(_selected),
        child: _buildSection(_selected),
      ),
    );

    final Widget mobileContent = PageView(
      controller: _pageController,
      onPageChanged: (int index) {
        setState(() => _selected = index);
      },
      children: <Widget>[
        const LinksView(),
        CategoriesView(onSelectCategory: _onCategorySelected),
        TagsView(onSelectTag: _onTagSelected),
        const SettingsView(),
      ],
    );

    final bool isMacOS =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

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
                Expanded(child: desktopContent),
              ],
            ),
          )
        : Scaffold(
            body: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  if (isMacOS) const SizedBox(height: 38),
                  Expanded(child: mobileContent),
                  const Rule(),
                  _BottomBar(
                    destinations: _destinations,
                    selected: _selected,
                    onSelect: _select,
                  ),
                ],
              ),
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
    final bool isMacOS =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    return Container(
      width: AppLayout.sidebarWidth,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                isMacOS ? AppSpacing.xxl : AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: const _Wordmark(),
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
          PixelIcons.circle,
          size: 22,
          color: AppColors.textPrimary,
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
