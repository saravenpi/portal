import 'category.dart';
import 'link_item.dart';

class PortalConfig {
  final String title;
  final List<Category> categories;

  const PortalConfig({
    this.title = 'Portal',
    this.categories = const <Category>[],
  });

  List<LinkItem> get allLinks => <LinkItem>[
        for (final Category category in categories) ...category.links,
      ];

  PortalConfig copyWith({
    String? title,
    List<Category>? categories,
  }) {
    return PortalConfig(
      title: title ?? this.title,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'categories': categories.map((Category cat) => cat.toMap()).toList(),
    };
  }

  factory PortalConfig.fromMap(Map<String, dynamic> map) {
    final dynamic rawCategories = map['categories'];
    final List<Category> parsedCategories;
    if (rawCategories is List<dynamic>) {
      parsedCategories = rawCategories
          .whereType<Map<String, dynamic>>()
          .map(Category.fromMap)
          .toList();
    } else {
      parsedCategories = const <Category>[];
    }

    return PortalConfig(
      title: (map['title'] as String?) ?? 'Portal',
      categories: parsedCategories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PortalConfig) return false;
    if (title != other.title || categories.length != other.categories.length) {
      return false;
    }
    for (int i = 0; i < categories.length; i++) {
      if (categories[i] != other.categories[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        title,
        Object.hashAll(categories),
      );

  @override
  String toString() {
    return 'PortalConfig(title: $title, categories: $categories)';
  }
}
