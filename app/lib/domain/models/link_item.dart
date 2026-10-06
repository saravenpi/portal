enum LinkHealth {
  unknown,
  healthy,
  broken,
}

class LinkItem {
  final String id;
  final String name;
  final String url;
  final String? description;
  final List<String> tags;
  final bool isPrivate;
  final bool isFavorite;
  final DateTime? createdAt;
  final String? faviconUrl;
  final LinkHealth health;

  const LinkItem({
    required this.id,
    required this.name,
    required this.url,
    this.description,
    this.tags = const <String>[],
    this.isPrivate = false,
    this.isFavorite = false,
    this.createdAt,
    this.faviconUrl,
    this.health = LinkHealth.unknown,
  });

  LinkItem copyWith({
    String? id,
    String? name,
    String? url,
    String? description,
    bool clearDescription = false,
    List<String>? tags,
    bool? isPrivate,
    bool? isFavorite,
    DateTime? createdAt,
    bool clearCreatedAt = false,
    String? faviconUrl,
    bool clearFaviconUrl = false,
    LinkHealth? health,
  }) {
    return LinkItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      description: clearDescription ? null : (description ?? this.description),
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      faviconUrl: clearFaviconUrl ? null : (faviconUrl ?? this.faviconUrl),
      health: health ?? this.health,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      if (description != null) 'description': description,
      if (tags.isNotEmpty) 'tags': tags,
      if (isPrivate) 'isPrivate': isPrivate,
      if (isFavorite) 'isFavorite': isFavorite,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (faviconUrl != null) 'faviconUrl': faviconUrl,
      'health': health.name,
    };
  }

  factory LinkItem.fromMap(Map<String, dynamic> map) {
    final dynamic rawTags = map['tags'] ?? map['tag'];
    final List<String> parsedTags;
    if (rawTags is List<dynamic>) {
      parsedTags = rawTags
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .toList();
    } else if (rawTags is String) {
      parsedTags = rawTags
          .split(',')
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList();
    } else {
      parsedTags = const <String>[];
    }

    final dynamic rawHealth = map['health'];
    final LinkHealth parsedHealth;
    if (rawHealth is String) {
      parsedHealth = LinkHealth.values.firstWhere(
        (LinkHealth h) => h.name == rawHealth,
        orElse: () => LinkHealth.unknown,
      );
    } else {
      parsedHealth = LinkHealth.unknown;
    }

    final dynamic rawCreatedAt = map['createdAt'];
    final DateTime? parsedCreatedAt =
        rawCreatedAt is String ? DateTime.tryParse(rawCreatedAt) : null;

    final dynamic rawPrivate = map['isPrivate'] ?? map['private'];
    final bool parsedPrivate = rawPrivate is bool ? rawPrivate : false;

    final dynamic rawFavorite =
        map['isFavorite'] ?? map['favorite'] ?? map['starred'];
    final bool parsedFavorite = rawFavorite is bool ? rawFavorite : false;

    return LinkItem(
      id: (map['id'] as String?) ??
          '${DateTime.now().microsecondsSinceEpoch}_${(map['url'] as String? ?? '').hashCode}',
      name: (map['name'] as String?) ?? '',
      url: (map['url'] as String?) ?? '',
      description: map['description'] as String?,
      tags: parsedTags,
      isPrivate: parsedPrivate,
      isFavorite: parsedFavorite,
      createdAt: parsedCreatedAt,
      faviconUrl: (map['faviconUrl'] ?? map['favicon']) as String?,
      health: parsedHealth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LinkItem) return false;
    if (id != other.id ||
        name != other.name ||
        url != other.url ||
        description != other.description ||
        isPrivate != other.isPrivate ||
        isFavorite != other.isFavorite ||
        createdAt != other.createdAt ||
        faviconUrl != other.faviconUrl ||
        health != other.health ||
        tags.length != other.tags.length) {
      return false;
    }
    for (int i = 0; i < tags.length; i++) {
      if (tags[i] != other.tags[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        url,
        description,
        Object.hashAll(tags),
        isPrivate,
        isFavorite,
        createdAt,
        faviconUrl,
        health,
      );

  @override
  String toString() {
    return 'LinkItem(id: $id, name: $name, url: $url, description: $description, tags: $tags, isPrivate: $isPrivate, isFavorite: $isFavorite, createdAt: $createdAt, faviconUrl: $faviconUrl, health: $health)';
  }
}
