import 'link_item.dart';

class LinkFilter {
  final String searchQuery;
  final String? categoryId;
  final String? selectedTag;
  final bool favoritesOnly;

  const LinkFilter({
    this.searchQuery = '',
    this.categoryId,
    this.selectedTag,
    this.favoritesOnly = false,
  });

  bool matches(LinkItem link, {String? categoryId}) {
    if (favoritesOnly && !link.isFavorite) {
      return false;
    }
    if (this.categoryId != null &&
        categoryId != null &&
        this.categoryId != categoryId) {
      return false;
    }
    if (selectedTag != null && selectedTag!.isNotEmpty) {
      final String tagLower = selectedTag!.toLowerCase();
      final bool hasTag = link.tags.any(
        (String t) => t.toLowerCase() == tagLower,
      );
      if (!hasTag) {
        return false;
      }
    }
    if (searchQuery.isNotEmpty) {
      final String query = searchQuery.toLowerCase();
      final bool matchesName = link.name.toLowerCase().contains(query);
      final bool matchesUrl = link.url.toLowerCase().contains(query);
      final bool matchesDesc =
          link.description?.toLowerCase().contains(query) ?? false;
      final bool matchesTags = link.tags.any(
        (String t) => t.toLowerCase().contains(query),
      );
      if (!matchesName && !matchesUrl && !matchesDesc && !matchesTags) {
        return false;
      }
    }
    return true;
  }

  LinkFilter copyWith({
    String? searchQuery,
    String? categoryId,
    bool clearCategoryId = false,
    String? selectedTag,
    bool clearSelectedTag = false,
    bool? favoritesOnly,
  }) {
    return LinkFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      selectedTag:
          clearSelectedTag ? null : (selectedTag ?? this.selectedTag),
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LinkFilter) return false;
    return searchQuery == other.searchQuery &&
        categoryId == other.categoryId &&
        selectedTag == other.selectedTag &&
        favoritesOnly == other.favoritesOnly;
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        categoryId,
        selectedTag,
        favoritesOnly,
      );

  @override
  String toString() {
    return 'LinkFilter(searchQuery: $searchQuery, categoryId: $categoryId, selectedTag: $selectedTag, favoritesOnly: $favoritesOnly)';
  }
}
