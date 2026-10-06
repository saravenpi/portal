import 'link_item.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final List<LinkItem> links;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.links = const <LinkItem>[],
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    bool clearDescription = false,
    List<LinkItem>? links,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      links: links ?? this.links,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'links': links.map((LinkItem link) => link.toMap()).toList(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    final dynamic rawLinks = map['links'];
    final List<LinkItem> parsedLinks;
    if (rawLinks is List<dynamic>) {
      parsedLinks = rawLinks
          .whereType<Map<String, dynamic>>()
          .map(LinkItem.fromMap)
          .toList();
    } else {
      parsedLinks = const <LinkItem>[];
    }

    return Category(
      id: (map['id'] as String?) ??
          '${DateTime.now().microsecondsSinceEpoch}_${(map['name'] as String? ?? '').hashCode}',
      name: (map['name'] as String?) ?? '',
      description: map['description'] as String?,
      links: parsedLinks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Category) return false;
    if (id != other.id ||
        name != other.name ||
        description != other.description ||
        links.length != other.links.length) {
      return false;
    }
    for (int i = 0; i < links.length; i++) {
      if (links[i] != other.links[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        Object.hashAll(links),
      );

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, links: $links)';
  }
}
