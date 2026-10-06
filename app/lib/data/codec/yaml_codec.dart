import 'package:yaml/yaml.dart' as yaml;
import '../../domain/models/category.dart';
import '../../domain/models/link_item.dart';
import '../../domain/models/portal_config.dart';

class YamlParseException implements Exception {
  final String message;
  final List<String> issues;

  const YamlParseException(this.message, [this.issues = const <String>[]]);

  @override
  String toString() {
    if (issues.isEmpty) {
      return 'YamlParseException: $message';
    }
    final String issueList = issues.map((String i) => '  - $i').join('\n');
    return 'YamlParseException: $message\n$issueList';
  }
}

class YamlCodec {
  static const Set<String> reservedRootKeys = <String>{
    'title',
    'name',
    'description',
    'links',
  };

  static const List<String> categoryContainerKeys = <String>[
    'categories',
    'sections',
    'projects',
    'portals',
    'groups',
  ];

  static const List<String> categoryNameKeys = <String>[
    'category',
    'name',
    'title',
    'section',
    'project',
    'group',
  ];

  static const List<String> categoryDescriptionKeys = <String>[
    'description',
    'desc',
    'details',
    'note',
  ];

  static const List<String> linkCollectionKeys = <String>[
    'links',
    'items',
    'entries',
    'bookmarks',
  ];

  static const List<String> linkNameKeys = <String>[
    'name',
    'title',
    'label',
  ];

  static const List<String> linkUrlKeys = <String>[
    'url',
    'href',
    'link',
    'to',
  ];

  static const List<String> linkDescriptionKeys = <String>[
    'description',
    'desc',
    'details',
    'note',
  ];

  static const String rootLinksCategoryName = 'Links';

  const YamlCodec();

  PortalConfig decode(String yamlContent) {
    if (yamlContent.trim().isEmpty) {
      throw const YamlParseException(
        'Empty file',
        <String>['root: No links or categories were found. Add root-level links or category sections.'],
      );
    }

    final dynamic loaded;
    try {
      loaded = yaml.loadYaml(yamlContent);
    } catch (e) {
      throw YamlParseException('YAML syntax error: $e');
    }

    if (loaded is! Map<dynamic, dynamic>) {
      throw const YamlParseException('Root YAML value must be a map.');
    }

    final List<String> issues = <String>[];
    final List<Category> categories = <Category>[];
    final List<LinkItem> rootLinks = <LinkItem>[];
    Category? rootLinksCategory;

    if (loaded.containsKey('links')) {
      issues.add(
        "links: Root-level 'links' is no longer supported. Move those entries to the root as '<name>: <url>' entries or put them inside a category.",
      );
    }

    for (final MapEntry<dynamic, dynamic> entry in loaded.entries) {
      final String key = entry.key.toString();
      final dynamic value = entry.value;

      if (key == 'title' ||
          key == 'name' ||
          key == 'description' ||
          key == 'links') {
        continue;
      }

      if (categoryContainerKeys.contains(key)) {
        categories.addAll(_parseCategoriesContainer(value, issues, key));
        continue;
      }

      if (_isRootLinkEntry(value)) {
        if (rootLinksCategory == null) {
          rootLinksCategory = Category(
            id: rootLinksCategoryName.hashCode.toString(),
            name: rootLinksCategoryName,
            links: rootLinks,
          );
          categories.add(rootLinksCategory);
        }
        rootLinks.addAll(_parseLinkEntry(value, key, issues, key));
        continue;
      }

      final Category? category =
          _parseCategory(key, value, issues, key, allowSingleLink: false);
      if (category != null) {
        categories.add(category);
      }
    }

    if (categories.isEmpty && issues.isEmpty) {
      issues.add(
        'root: No links or categories were found. Add root-level links or category sections.',
      );
    }

    if (issues.isNotEmpty) {
      throw YamlParseException('Invalid portal configuration', issues);
    }

    final dynamic titleVal = loaded['title'] ?? loaded['name'];
    final String finalTitle =
        titleVal is String && titleVal.trim().isNotEmpty
            ? titleVal.trim()
            : 'Portal';

    final List<Category> mergedCategories = <Category>[];
    for (final Category cat in categories) {
      if (identical(cat, rootLinksCategory)) {
        mergedCategories
            .add(cat.copyWith(links: List<LinkItem>.unmodifiable(rootLinks)));
      } else {
        mergedCategories.add(cat);
      }
    }

    return PortalConfig(
      title: finalTitle,
      categories: mergedCategories,
    );
  }

  String encode(PortalConfig config) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('title: ${_escapeYamlString(config.title)}');

    for (final Category category in config.categories) {
      buffer.writeln();
      buffer.writeln('${_escapeYamlKey(category.name)}:');
      if (category.description != null &&
          category.description!.trim().isNotEmpty) {
        buffer.writeln(
          '  description: ${_escapeYamlString(category.description!.trim())}',
        );
        buffer.writeln('  links:');
        for (final LinkItem link in category.links) {
          _writeLinkYaml(buffer, link, '    ');
        }
      } else {
        for (final LinkItem link in category.links) {
          _writeLinkYaml(buffer, link, '  ');
        }
      }
    }

    return buffer.toString();
  }

  void _writeLinkYaml(StringBuffer buffer, LinkItem link, String indent) {
    buffer.writeln('$indent- name: ${_escapeYamlString(link.name)}');
    buffer.writeln('$indent  url: ${_escapeYamlString(link.url)}');
    if (link.description != null && link.description!.trim().isNotEmpty) {
      buffer.writeln(
        '$indent  description: ${_escapeYamlString(link.description!.trim())}',
      );
    }
    if (link.tags.isNotEmpty) {
      final String tagsFormatted =
          link.tags.map(_escapeYamlString).join(', ');
      buffer.writeln('$indent  tags: [$tagsFormatted]');
    }
    if (link.isPrivate) {
      buffer.writeln('$indent  private: true');
    }
    if (link.isFavorite) {
      buffer.writeln('$indent  favorite: true');
    }
    if (link.faviconUrl != null && link.faviconUrl!.trim().isNotEmpty) {
      buffer.writeln(
        '$indent  favicon: ${_escapeYamlString(link.faviconUrl!.trim())}',
      );
    }
  }

  static String _escapeYamlString(String str) {
    if (str.isEmpty) return "''";
    if (str.contains('\n') || str.contains('"') || str.contains('\\')) {
      final String escaped = str
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\n', '\\n');
      return '"$escaped"';
    }
    if (RegExp(r'[:#\[\]{},&*?|<>=!%@`]').hasMatch(str) ||
        str.startsWith(' ') ||
        str.endsWith(' ') ||
        str.startsWith('-')) {
      final String escaped = str.replaceAll("'", "''");
      return "'$escaped'";
    }
    return str;
  }

  static String _escapeYamlKey(String key) {
    if (RegExp(r'[:#\[\]{},&*?|<>=!%@`\s]').hasMatch(key)) {
      final String escaped = key.replaceAll("'", "''");
      return "'$escaped'";
    }
    return key;
  }

  static String? _getFirstString(
    Map<dynamic, dynamic> record,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic val = record[key];
      if (val is String && val.trim().isNotEmpty) {
        return val.trim();
      }
    }
    return null;
  }

  static String _normalizeUrl(String value) {
    final String trimmed = value.trim();
    if (RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false)
        .hasMatch(trimmed)) {
      return trimmed;
    }
    if (trimmed.startsWith('www.')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  static bool _looksLikeUrl(String value) {
    final String trimmed = value.trim();
    return RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false)
            .hasMatch(trimmed) ||
        trimmed.startsWith('www.');
  }

  static String _deriveNameFromUrl(String value) {
    final String normalized = _normalizeUrl(value);
    try {
      final Uri uri = Uri.parse(normalized);
      final String host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
      final String path = uri.path.replaceFirst(RegExp(r'/$'), '');
      if (path.isNotEmpty && path != '/') {
        return '$host$path';
      }
      return host.isNotEmpty ? host : normalized;
    } catch (_) {
      return normalized;
    }
  }

  static List<String> _normalizeTags(dynamic value) {
    if (value is List<dynamic>) {
      return value
          .map((dynamic tag) => tag.toString().trim())
          .where((String tag) => tag.isNotEmpty)
          .toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((String tag) => tag.trim())
          .where((String tag) => tag.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  static bool _isMetadataOnlyKey(String key) {
    return linkNameKeys.contains(key) ||
        linkUrlKeys.contains(key) ||
        linkDescriptionKeys.contains(key) ||
        key == 'private' ||
        key == 'isPrivate' ||
        key == 'favorite' ||
        key == 'isFavorite' ||
        key == 'starred' ||
        key == 'tags' ||
        key == 'tag' ||
        key == 'favicon' ||
        key == 'faviconUrl' ||
        key == 'createdAt' ||
        key == 'id';
  }

  static bool _isLikelyLinkRecord(Map<dynamic, dynamic> record) {
    for (final String key in linkUrlKeys) {
      if (record.containsKey(key)) {
        return true;
      }
    }
    final List<String> stringKeys =
        record.keys.map((dynamic k) => k.toString()).toList();
    if (stringKeys.isEmpty) {
      return false;
    }
    if (stringKeys.every(_isMetadataOnlyKey)) {
      return true;
    }
    if (stringKeys.length == 1) {
      return _isMetadataOnlyKey(stringKeys.first);
    }
    return false;
  }

  static bool _isRootLinkEntry(dynamic value) {
    return value is String ||
        (value is Map<dynamic, dynamic> && _isLikelyLinkRecord(value));
  }

  static LinkItem? _parseLinkShorthand(
    String value,
    String? fallbackName,
    List<String> issues,
    String issuePath,
  ) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      issues.add(
        '$issuePath: Expected a URL or link shorthand, but found an empty string.',
      );
      return null;
    }
    if (_looksLikeUrl(trimmed)) {
      final String derivedName = fallbackName ?? _deriveNameFromUrl(trimmed);
      final String normalizedUrl = _normalizeUrl(trimmed);
      return LinkItem(
        id: '${derivedName}_$normalizedUrl'.hashCode.toString(),
        name: derivedName,
        url: normalizedUrl,
      );
    }

    final List<RegExp> patterns = <RegExp>[
      RegExp(r'^(.*?)\s*(?:->|=>|\|)\s*(\S+)$'),
      RegExp(r'^(.*?)\s*:\s*(\S+)$'),
      RegExp(r'^(.*?)\s+(\S+)$'),
    ];

    for (final RegExp pattern in patterns) {
      final Match? match = pattern.firstMatch(trimmed);
      if (match == null) continue;
      final String rawName = match.group(1) ?? '';
      final String rawUrl = match.group(2) ?? '';
      if (!_looksLikeUrl(rawUrl)) continue;

      final String finalName = rawName.trim().isNotEmpty
          ? rawName.trim()
          : (fallbackName ?? _deriveNameFromUrl(rawUrl));
      final String normalizedUrl = _normalizeUrl(rawUrl);
      return LinkItem(
        id: '${finalName}_$normalizedUrl'.hashCode.toString(),
        name: finalName,
        url: normalizedUrl,
      );
    }

    if (fallbackName != null) {
      issues.add(
        "$issuePath: Expected a URL for '$fallbackName', but got '$trimmed'. Use a full URL or '<name> -> <url>'.",
      );
      return null;
    }

    issues.add(
      "$issuePath: Expected a URL or '<name> -> <url>' entry, but got '$trimmed'.",
    );
    return null;
  }

  static LinkItem _toLink(
    String name,
    String url, [
    Map<dynamic, dynamic>? record,
  ]) {
    final String trimmedName = name.trim();
    final String normalizedUrl = _normalizeUrl(url);
    final List<String> tags = record != null
        ? _normalizeTags(record['tags'] ?? record['tag'])
        : const <String>[];
    final String? desc =
        record != null ? _getFirstString(record, linkDescriptionKeys) : null;
    final bool isPrivate = record != null &&
        (record['private'] == true || record['isPrivate'] == true);
    final bool isFavorite = record != null &&
        (record['favorite'] == true ||
            record['isFavorite'] == true ||
            record['starred'] == true);
    final String? favicon = record != null
        ? _getFirstString(record, const <String>['favicon', 'faviconUrl'])
        : null;
    final dynamic rawCreatedAt = record?['createdAt'];
    final DateTime? createdAt =
        rawCreatedAt is String ? DateTime.tryParse(rawCreatedAt) : null;
    final String? id = record?['id'] as String?;

    return LinkItem(
      id: id ?? '${trimmedName}_$normalizedUrl'.hashCode.toString(),
      name: trimmedName,
      url: normalizedUrl,
      description: desc,
      tags: tags,
      isPrivate: isPrivate,
      isFavorite: isFavorite,
      createdAt: createdAt,
      faviconUrl: favicon,
      health: LinkHealth.unknown,
    );
  }

  static List<LinkItem> _parseLinkEntry(
    dynamic entry,
    String? fallbackName,
    List<String> issues,
    String issuePath,
  ) {
    if (entry is String) {
      final LinkItem? parsed =
          _parseLinkShorthand(entry, fallbackName, issues, issuePath);
      return parsed != null ? <LinkItem>[parsed] : const <LinkItem>[];
    }

    if (entry == null) {
      issues.add('$issuePath: Link entry is empty. Expected a URL or link object.');
      return const <LinkItem>[];
    }

    if (entry is List<dynamic>) {
      issues.add(
        '$issuePath: Link entry cannot be a list. Put lists inside a category.',
      );
      return const <LinkItem>[];
    }

    if (entry is! Map<dynamic, dynamic>) {
      issues.add(
        "$issuePath: Unsupported link entry type '${entry.runtimeType}'. Expected a string or object.",
      );
      return const <LinkItem>[];
    }

    final String? explicitName =
        _getFirstString(entry, linkNameKeys) ?? fallbackName;
    final String? explicitUrl = _getFirstString(entry, linkUrlKeys);
    final List<String> entryKeys =
        entry.keys.map((dynamic k) => k.toString()).toList();

    if (explicitName != null && explicitUrl != null) {
      return <LinkItem>[_toLink(explicitName, explicitUrl, entry)];
    }

    if (explicitName == null && explicitUrl != null) {
      return <LinkItem>[
        _toLink(_deriveNameFromUrl(explicitUrl), explicitUrl, entry),
      ];
    }

    if (entryKeys.isNotEmpty && entryKeys.every(_isMetadataOnlyKey)) {
      issues.add(
        "Link '${fallbackName ?? issuePath}' is missing a URL. Use one of ${linkUrlKeys.join(', ')}.",
      );
      return const <LinkItem>[];
    }

    if (entryKeys.length == 1) {
      final dynamic singleKey = entry.keys.first;
      final dynamic singleVal = entry[singleKey];
      return _parseLinkEntry(
        singleVal,
        singleKey.toString(),
        issues,
        '$issuePath.${singleKey.toString()}',
      );
    }

    final List<LinkItem> links = <LinkItem>[];
    for (final MapEntry<dynamic, dynamic> pair in entry.entries) {
      final String key = pair.key.toString();
      if (_isMetadataOnlyKey(key)) {
        continue;
      }
      links.addAll(_parseLinkEntry(pair.value, key, issues, '$issuePath.$key'));
    }

    if (links.isEmpty) {
      issues.add(
        "Could not understand this link object. Expected one of ${linkUrlKeys.join(', ')} or a single '<name>: <url>' entry.",
      );
    }

    return links;
  }

  static List<LinkItem> _parseLinksCollection(
    dynamic value,
    List<String> issues,
    String issuePath,
  ) {
    if (value is List<dynamic>) {
      final List<LinkItem> result = <LinkItem>[];
      for (int i = 0; i < value.length; i++) {
        result.addAll(
          _parseLinkEntry(value[i], null, issues, '$issuePath[$i]'),
        );
      }
      return result;
    }

    if (value is Map<dynamic, dynamic>) {
      final List<LinkItem> result = <LinkItem>[];
      for (final MapEntry<dynamic, dynamic> pair in value.entries) {
        final String key = pair.key.toString();
        result.addAll(
          _parseLinkEntry(pair.value, key, issues, '$issuePath.$key'),
        );
      }
      return result;
    }

    if (value is String) {
      return _parseLinkEntry(value, null, issues, issuePath);
    }

    issues.add(
      "Expected a list of links, a map of links, or a link string. Got '${value.runtimeType}' instead.",
    );
    return const <LinkItem>[];
  }

  static Category? _parseCategory(
    String name,
    dynamic value,
    List<String> issues,
    String issuePath, {
    bool allowSingleLink = true,
  }) {
    if (value == null) {
      issues.add("Category '$name' is empty.");
      return null;
    }

    String? description;
    final List<LinkItem> links = <LinkItem>[];

    if (value is List<dynamic>) {
      links.addAll(_parseLinksCollection(value, issues, issuePath));
    } else if (value is Map<dynamic, dynamic>) {
      description = _getFirstString(value, categoryDescriptionKeys);

      for (final String colKey in linkCollectionKeys) {
        if (value.containsKey(colKey)) {
          links.addAll(
            _parseLinksCollection(value[colKey], issues, '$issuePath.$colKey'),
          );
        }
      }

      final Iterable<MapEntry<dynamic, dynamic>> directEntries =
          value.entries.where((MapEntry<dynamic, dynamic> pair) {
        final String key = pair.key.toString();
        if (categoryNameKeys.contains(key) ||
            categoryDescriptionKeys.contains(key)) {
          return false;
        }
        if (linkCollectionKeys.contains(key)) {
          return false;
        }
        return true;
      });

      for (final MapEntry<dynamic, dynamic> pair in directEntries) {
        final String key = pair.key.toString();
        links.addAll(
          _parseLinkEntry(pair.value, key, issues, '$issuePath.$key'),
        );
      }
    } else if (value is String) {
      if (!allowSingleLink) {
        issues.add(
          "Top-level category '$name' must be a map or list of links. For a single link, move it to the root as '<name>: <url>'.",
        );
        return null;
      }
      links.addAll(_parseLinkEntry(value, name, issues, issuePath));
    } else {
      issues.add(
        "Category '$name' has unsupported type '${value.runtimeType}'. Expected a map, list, or URL string.",
      );
      return null;
    }

    if (links.isEmpty) {
      issues.add("Category '$name' does not contain any valid links.");
      return null;
    }

    return Category(
      id: name.hashCode.toString(),
      name: name,
      description: description,
      links: links,
    );
  }

  static List<Category> _parseCategoryEntry(
    dynamic entry,
    String? fallbackName,
    List<String> issues,
    String issuePath,
  ) {
    if (entry is! Map<dynamic, dynamic>) {
      issues.add('Category entry must be an object.');
      return const <Category>[];
    }

    final String? explicitName =
        _getFirstString(entry, categoryNameKeys) ?? fallbackName;
    if (explicitName != null) {
      final Category? category = _parseCategory(
        explicitName,
        entry,
        issues,
        issuePath,
        allowSingleLink: false,
      );
      return category != null ? <Category>[category] : const <Category>[];
    }

    if (entry.length == 1) {
      final dynamic singleKey = entry.keys.first;
      final dynamic singleVal = entry[singleKey];
      final Category? category = _parseCategory(
        singleKey.toString(),
        singleVal,
        issues,
        '$issuePath.${singleKey.toString()}',
        allowSingleLink: false,
      );
      return category != null ? <Category>[category] : const <Category>[];
    }

    issues.add(
      "Could not determine the category name. Use one of ${categoryNameKeys.join(', ')}.",
    );
    return const <Category>[];
  }

  static List<Category> _parseCategoriesContainer(
    dynamic value,
    List<String> issues,
    String issuePath,
  ) {
    if (value is List<dynamic>) {
      final List<Category> list = <Category>[];
      for (int i = 0; i < value.length; i++) {
        list.addAll(
          _parseCategoryEntry(value[i], null, issues, '$issuePath[$i]'),
        );
      }
      return list;
    }

    if (value is Map<dynamic, dynamic>) {
      final List<Category> list = <Category>[];
      for (final MapEntry<dynamic, dynamic> pair in value.entries) {
        final String key = pair.key.toString();
        final Category? cat = _parseCategory(
          key,
          pair.value,
          issues,
          '$issuePath.$key',
          allowSingleLink: false,
        );
        if (cat != null) {
          list.add(cat);
        }
      }
      return list;
    }

    issues.add(
      "Expected a categories container to be a list or map. Got '${value.runtimeType}' instead.",
    );
    return const <Category>[];
  }
}
