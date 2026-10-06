import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:portal/domain/models/category.dart';
import 'package:portal/domain/models/link_filter.dart';
import 'package:portal/domain/models/link_item.dart';
import 'package:portal/domain/models/portal_config.dart';
import 'package:portal/domain/services/link_validator.dart';
import 'package:portal/domain/services/metadata_fetcher.dart';

void main() {
  group('LinkItem model', () {
    test('serialization roundtrip and copyWith', () {
      final DateTime now = DateTime.now();
      final LinkItem item = LinkItem(
        id: '1',
        name: 'Test',
        url: 'https://example.com',
        description: 'A test link',
        tags: const <String>['test', 'portal'],
        isPrivate: true,
        isFavorite: true,
        createdAt: now,
        faviconUrl: 'https://example.com/favicon.ico',
        health: LinkHealth.healthy,
      );

      final Map<String, dynamic> map = item.toMap();
      final LinkItem fromMap = LinkItem.fromMap(map);

      expect(fromMap.id, item.id);
      expect(fromMap.name, item.name);
      expect(fromMap.url, item.url);
      expect(fromMap.description, item.description);
      expect(fromMap.tags, item.tags);
      expect(fromMap.isPrivate, item.isPrivate);
      expect(fromMap.isFavorite, item.isFavorite);
      expect(fromMap.health, item.health);
      expect(fromMap.faviconUrl, item.faviconUrl);

      final LinkItem updated = item.copyWith(name: 'Updated Name', clearDescription: true);
      expect(updated.name, 'Updated Name');
      expect(updated.description, isNull);
    });
  });

  group('Category and PortalConfig models', () {
    test('Category and PortalConfig serialization', () {
      const Category category = Category(
        id: 'c1',
        name: 'Work',
        description: 'Work resources',
        links: <LinkItem>[
          LinkItem(id: 'l1', name: 'Work Email', url: 'https://mail.work.com'),
        ],
      );

      final Map<String, dynamic> catMap = category.toMap();
      final Category fromCatMap = Category.fromMap(catMap);
      expect(fromCatMap.name, 'Work');
      expect(fromCatMap.links.length, 1);

      const PortalConfig config = PortalConfig(
        title: 'Master Portal',
        categories: <Category>[category],
      );

      expect(config.allLinks.length, 1);
      final Map<String, dynamic> configMap = config.toMap();
      final PortalConfig fromConfigMap = PortalConfig.fromMap(configMap);
      expect(fromConfigMap.title, 'Master Portal');
      expect(fromConfigMap.categories.length, 1);
    });
  });

  group('LinkFilter', () {
    const LinkItem link1 = LinkItem(
      id: '1',
      name: 'Flutter Dev',
      url: 'https://flutter.dev',
      tags: <String>['flutter', 'mobile'],
      isFavorite: true,
      isPrivate: false,
    );

    const LinkItem link2 = LinkItem(
      id: '2',
      name: 'Secret Vault',
      url: 'https://vault.internal',
      tags: <String>['security'],
      isFavorite: false,
      isPrivate: true,
    );

    test('matches search query, tags, favorites, and privacy', () {
      const LinkFilter filterAll = LinkFilter();
      expect(filterAll.matches(link1), isTrue);
      expect(filterAll.matches(link2), isTrue);

      const LinkFilter filterQuery = LinkFilter(searchQuery: 'flutter');
      expect(filterQuery.matches(link1), isTrue);
      expect(filterQuery.matches(link2), isFalse);

      const LinkFilter filterTag = LinkFilter(selectedTag: 'mobile');
      expect(filterTag.matches(link1), isTrue);
      expect(filterTag.matches(link2), isFalse);

      const LinkFilter filterFavorites = LinkFilter(favoritesOnly: true);
      expect(filterFavorites.matches(link1), isTrue);
      expect(filterFavorites.matches(link2), isFalse);

      const LinkFilter filterNoPrivate = LinkFilter(includePrivate: false);
      expect(filterNoPrivate.matches(link1), isTrue);
      expect(filterNoPrivate.matches(link2), isFalse);
    });
  });

  group('MetadataFetcher', () {
    test('extracts og:title, og:description, and favicon', () async {
      final MockClient client = MockClient((http.Request request) async {
        const String html = '''
<!DOCTYPE html>
<html>
<head>
  <title>Fallback Title</title>
  <meta property="og:title" content="OpenGraph Title">
  <meta property="og:description" content="OpenGraph Description">
  <link rel="icon" href="/custom-icon.png">
</head>
<body></body>
</html>
''';
        return http.Response(html, 200, headers: <String, String>{'content-type': 'text/html'});
      });

      final MetadataFetcher fetcher = MetadataFetcher(client: client);
      final MetadataResult result = await fetcher.fetchMetadata('https://example.com');

      expect(result.title, 'OpenGraph Title');
      expect(result.description, 'OpenGraph Description');
      expect(result.faviconUrl, 'https://example.com/custom-icon.png');
    });

    test('handles network failure safely', () async {
      final MockClient client = MockClient((http.Request request) async {
        throw http.ClientException('Network down');
      });

      final MetadataFetcher fetcher = MetadataFetcher(client: client);
      final MetadataResult result = await fetcher.fetchMetadata('https://example.com');

      expect(result.title, isNull);
      expect(result.description, isNull);
      expect(result.faviconUrl, isNull);
    });
  });

  group('LinkValidator', () {
    test('reports healthy on 200 and broken on 404', () async {
      final MockClient client = MockClient((http.Request request) async {
        if (request.url.toString() == 'https://ok.com') {
          return http.Response('OK', 200);
        }
        return http.Response('Not Found', 404);
      });

      final LinkValidator validator = LinkValidator(client: client);
      final LinkHealth okHealth = await validator.checkHealth('https://ok.com');
      final LinkHealth failHealth = await validator.checkHealth('https://bad.com');

      expect(okHealth, LinkHealth.healthy);
      expect(failHealth, LinkHealth.broken);
    });
  });
}
