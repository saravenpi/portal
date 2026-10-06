import 'package:flutter_test/flutter_test.dart';
import 'package:portal/data/codec/yaml_codec.dart';
import 'package:portal/domain/models/category.dart';
import 'package:portal/domain/models/link_item.dart';
import 'package:portal/domain/models/portal_config.dart';

void main() {
  const YamlCodec codec = YamlCodec();

  group('YamlCodec decode', () {
    test('parses simple root-level links', () {
      const String yaml = '''
title: Simple Portal

GitHub: https://github.com
Docs: https://docs.example.com
''';

      final PortalConfig config = codec.decode(yaml);
      expect(config.title, 'Simple Portal');
      expect(config.categories.length, 1);
      expect(config.categories.first.name, 'Links');
      expect(config.categories.first.links.length, 2);
      expect(config.categories.first.links[0].name, 'GitHub');
      expect(config.categories.first.links[0].url, 'https://github.com');
      expect(config.categories.first.links[1].name, 'Docs');
      expect(config.categories.first.links[1].url, 'https://docs.example.com');
    });

    test('parses category maps with link metadata', () {
      const String yaml = '''
title: Category Map

Development:
  Repo: https://github.com/example/repo
  Docs:
    href: https://docs.example.com
    desc: Reference docs
    tags: docs, reference
''';

      final PortalConfig config = codec.decode(yaml);
      expect(config.title, 'Category Map');
      expect(config.categories.length, 1);

      final Category cat = config.categories.first;
      expect(cat.name, 'Development');
      expect(cat.links.length, 2);

      final LinkItem repo = cat.links[0];
      expect(repo.name, 'Repo');
      expect(repo.url, 'https://github.com/example/repo');

      final LinkItem docs = cat.links[1];
      expect(docs.name, 'Docs');
      expect(docs.url, 'https://docs.example.com');
      expect(docs.description, 'Reference docs');
      expect(docs.tags, <String>['docs', 'reference']);
    });

    test('parses category list and shorthand formats', () {
      const String yaml = '''
title: Category List

categories:
  - category: Development
    links:
      - GitHub -> https://github.com
      - name: Bun
        url: https://bun.sh
  - Design:
      - https://figma.com
''';

      final PortalConfig config = codec.decode(yaml);
      expect(config.title, 'Category List');
      expect(config.categories.length, 2);

      final Category dev = config.categories[0];
      expect(dev.name, 'Development');
      expect(dev.links.length, 2);
      expect(dev.links[0].name, 'GitHub');
      expect(dev.links[0].url, 'https://github.com');
      expect(dev.links[1].name, 'Bun');
      expect(dev.links[1].url, 'https://bun.sh');

      final Category design = config.categories[1];
      expect(design.name, 'Design');
      expect(design.links.length, 1);
      expect(design.links[0].name, 'figma.com');
      expect(design.links[0].url, 'https://figma.com');
    });

    test('throws YamlParseException on missing url', () {
      const String yaml = '''
title: Missing URL

Development:
  Docs:
    description: no url here
''';

      expect(
        () => codec.decode(yaml),
        throwsA(isA<YamlParseException>()),
      );
    });

    test('throws YamlParseException on root-level links container', () {
      const String yaml = '''
title: Bad Wrapper

links:
  - Docs -> https://docs.example.com
''';

      expect(
        () => codec.decode(yaml),
        throwsA(isA<YamlParseException>()),
      );
    });

    test('throws YamlParseException on empty document', () {
      expect(
        () => codec.decode('   \n  \n'),
        throwsA(isA<YamlParseException>()),
      );
    });
  });

  group('YamlCodec encode and roundtrip', () {
    test('encodes and decodes back cleanly', () {
      const PortalConfig original = PortalConfig(
        title: 'Roundtrip Portal',
        categories: <Category>[
          Category(
            id: 'dev_1',
            name: 'Development',
            description: 'Engineering tools',
            links: <LinkItem>[
              LinkItem(
                id: 'link_1',
                name: 'GitHub',
                url: 'https://github.com',
                description: 'Code repository',
                tags: <String>['git', 'code'],
                isFavorite: true,
              ),
              LinkItem(
                id: 'link_2',
                name: 'Private Console',
                url: 'https://console.internal',
                isFavorite: false,
              ),
            ],
          ),
        ],
      );

      final String encoded = codec.encode(original);
      final PortalConfig roundtripped = codec.decode(encoded);

      expect(roundtripped.title, original.title);
      expect(roundtripped.categories.length, 1);

      final Category cat = roundtripped.categories.first;
      expect(cat.name, 'Development');
      expect(cat.description, 'Engineering tools');
      expect(cat.links.length, 2);

      final LinkItem l1 = cat.links[0];
      expect(l1.name, 'GitHub');
      expect(l1.url, 'https://github.com');
      expect(l1.description, 'Code repository');
      expect(l1.tags, <String>['git', 'code']);
      expect(l1.isFavorite, isTrue);

      final LinkItem l2 = cat.links[1];
      expect(l2.name, 'Private Console');
      expect(l2.url, 'https://console.internal');
      expect(l2.isFavorite, isFalse);
    });
  });
}
