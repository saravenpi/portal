import 'package:flutter/foundation.dart' hide Category;

import '../../../data/storage/portal_vault.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/link_filter.dart';
import '../../../domain/models/link_item.dart';

class CategorizedLink {
  const CategorizedLink({
    required this.link,
    required this.categoryId,
    required this.categoryName,
  });

  final LinkItem link;
  final String categoryId;
  final String categoryName;
}

class LinksViewModel extends ChangeNotifier {
  LinksViewModel({required this.vault}) {
    vault.addListener(_onVaultChanged);
  }

  final PortalVault vault;
  LinkFilter _filter = const LinkFilter();
  bool _isCardView = false;

  LinkFilter get filter => _filter;
  bool get isCardView => _isCardView;

  List<Category> get categories => vault.categories;
  List<LinkItem> get allLinks => vault.allLinks;
  List<String> get allDistinctTags => vault.allDistinctTags;

  List<CategorizedLink> get filteredLinks {
    final List<CategorizedLink> results = <CategorizedLink>[];
    for (final Category category in vault.categories) {
      for (final LinkItem link in category.links) {
        if (_filter.matches(link, categoryId: category.id)) {
          results.add(
            CategorizedLink(
              link: link,
              categoryId: category.id,
              categoryName: category.name,
            ),
          );
        }
      }
    }
    return results;
  }

  int get totalCount => vault.allLinks.length;
  int get filteredCount => filteredLinks.length;

  void setSearchQuery(String query) {
    if (_filter.searchQuery == query) return;
    _filter = _filter.copyWith(searchQuery: query);
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    if (_filter.categoryId == categoryId) return;
    _filter = _filter.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
    );
    notifyListeners();
  }

  void setSelectedTag(String? tag) {
    if (_filter.selectedTag == tag) return;
    _filter = _filter.copyWith(
      selectedTag: tag,
      clearSelectedTag: tag == null,
    );
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    if (_filter.favoritesOnly == value) return;
    _filter = _filter.copyWith(favoritesOnly: value);
    notifyListeners();
  }

  void setIncludePrivate(bool value) {
    if (_filter.includePrivate == value) return;
    _filter = _filter.copyWith(includePrivate: value);
    notifyListeners();
  }

  void setDensity(bool isCardView) {
    if (_isCardView == isCardView) return;
    _isCardView = isCardView;
    notifyListeners();
  }

  void clearFilters() {
    _filter = const LinkFilter();
    notifyListeners();
  }

  Future<void> addLink({
    required String categoryId,
    required LinkItem link,
  }) async {
    await vault.addLink(categoryId: categoryId, link: link);
  }

  Future<void> updateLink({
    required String categoryId,
    required LinkItem link,
  }) async {
    await vault.updateLink(categoryId: categoryId, link: link);
  }

  Future<void> deleteLink({
    required String categoryId,
    required String linkId,
  }) async {
    await vault.deleteLink(categoryId: categoryId, linkId: linkId);
  }

  Future<void> toggleFavorite({
    required String categoryId,
    required String linkId,
  }) async {
    await vault.toggleFavorite(categoryId: categoryId, linkId: linkId);
  }

  Future<void> togglePrivate({
    required String categoryId,
    required String linkId,
  }) async {
    await vault.togglePrivate(categoryId: categoryId, linkId: linkId);
  }

  void _onVaultChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    try {
      vault.removeListener(_onVaultChanged);
    } catch (_) {}
    super.dispose();
  }
}
