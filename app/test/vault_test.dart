import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal/data/codec/yaml_codec.dart';
import 'package:portal/data/storage/portal_vault.dart';
import 'package:portal/domain/models/category.dart';
import 'package:portal/domain/models/link_item.dart';
import 'package:portal/domain/models/portal_config.dart';

void main() {
  late Directory tempDir;
  late PortalVault vault;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('portal_vault_test_');
    vault = PortalVault(
      vaultDirectory: tempDir.path,
      activeFileName: 'portal.yml',
      initialConfig: const PortalConfig(
        title: 'Initial Vault',
        categories: <Category>[
          Category(
            id: 'cat_dev',
            name: 'Development',
            links: <LinkItem>[
              LinkItem(
                id: 'link_gh',
                name: 'GitHub',
                url: 'https://github.com',
                tags: <String>['git', 'dev'],
                isFavorite: false,
              ),
            ],
          ),
        ],
      ),
    );
  });

  tearDown(() async {
    vault.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('load creates initial file if missing', () async {
    final File target = File('${tempDir.path}/portal.yml');
    expect(target.existsSync(), isFalse);

    await vault.load(createIfMissing: true);

    expect(target.existsSync(), isTrue);
    expect(vault.categories.isNotEmpty, isTrue);
    expect(vault.allLinks.isNotEmpty, isTrue);
  });

  test('addLink updates state, tags, and notifies listeners', () async {
    int notifications = 0;
    vault.addListener(() {
      notifications++;
    });

    const LinkItem newLink = LinkItem(
      id: 'link_dart',
      name: 'Dart',
      url: 'https://dart.dev',
      tags: <String>['language', 'dev'],
    );

    await vault.addLink(categoryId: 'cat_dev', link: newLink);

    expect(notifications, 1);
    expect(vault.allLinks.length, 2);
    expect(vault.allLinks.any((LinkItem l) => l.id == 'link_dart'), isTrue);
    expect(vault.allDistinctTags, <String>['dev', 'git', 'language']);

    await vault.flush();
    final File savedFile = File(vault.activeFilePath);
    expect(savedFile.existsSync(), isTrue);
    final String content = await savedFile.readAsString();
    expect(content.contains('Dart'), isTrue);
  });

  test('updateLink modifies existing link', () async {
    const LinkItem updated = LinkItem(
      id: 'link_gh',
      name: 'GitHub Enterprise',
      url: 'https://github.example.com',
      tags: <String>['enterprise'],
      isFavorite: true,
    );

    await vault.updateLink(categoryId: 'cat_dev', link: updated);

    final LinkItem current =
        vault.allLinks.firstWhere((LinkItem l) => l.id == 'link_gh');
    expect(current.name, 'GitHub Enterprise');
    expect(current.url, 'https://github.example.com');
    expect(current.isFavorite, isTrue);
  });

  test('deleteLink removes target link', () async {
    await vault.deleteLink(categoryId: 'cat_dev', linkId: 'link_gh');
    expect(vault.allLinks.isEmpty, isTrue);
  });

  test('moveLink moves link between categories', () async {
    const Category designCat = Category(
      id: 'cat_design',
      name: 'Design',
      links: <LinkItem>[],
    );
    await vault.addCategory(designCat);

    await vault.moveLink(
      linkId: 'link_gh',
      fromCategoryId: 'cat_dev',
      toCategoryId: 'cat_design',
    );

    final Category dev =
        vault.categories.firstWhere((Category c) => c.id == 'cat_dev');
    final Category design =
        vault.categories.firstWhere((Category c) => c.id == 'cat_design');

    expect(dev.links.isEmpty, isTrue);
    expect(design.links.length, 1);
    expect(design.links.first.id, 'link_gh');
  });

  test('category CRUD methods work as expected', () async {
    const Category tools = Category(
      id: 'cat_tools',
      name: 'Tools',
      description: 'Useful utilities',
    );
    await vault.addCategory(tools);
    expect(vault.categories.length, 2);

    const Category updatedTools = Category(
      id: 'cat_tools',
      name: 'Dev Tools',
      description: 'Updated tools',
    );
    await vault.updateCategory(updatedTools);

    final Category found =
        vault.categories.firstWhere((Category c) => c.id == 'cat_tools');
    expect(found.name, 'Dev Tools');

    await vault.deleteCategory('cat_tools');
    expect(vault.categories.length, 1);
  });

  test('toggleFavorite flips boolean', () async {
    await vault.toggleFavorite(categoryId: 'cat_dev', linkId: 'link_gh');
    expect(vault.allLinks.first.isFavorite, isTrue);

    await vault.toggleFavorite(categoryId: 'cat_dev', linkId: 'link_gh');
    expect(vault.allLinks.first.isFavorite, isFalse);
  });

  test('exportHtml generates clean html string and file', () async {
    final String html = await vault.exportHtml();
    expect(html.contains('<!DOCTYPE html>'), isTrue);
    expect(html.contains('GitHub'), isTrue);

    final File exported = File('${tempDir.path}/index.html');
    expect(exported.existsSync(), isTrue);
  });

  test('flush executes atomic write with temp file cleanup', () async {
    await vault.addLink(
      categoryId: 'cat_dev',
      link: const LinkItem(
        id: 'link_atomic',
        name: 'Atomic',
        url: 'https://example.com/atomic',
      ),
    );

    await vault.flush();

    final File mainFile = File(vault.activeFilePath);
    final File tmpFile = File('${vault.activeFilePath}.tmp');

    expect(mainFile.existsSync(), isTrue);
    expect(tmpFile.existsSync(), isFalse);

    const YamlCodec codec = YamlCodec();
    final PortalConfig parsed = codec.decode(await mainFile.readAsString());
    expect(parsed.allLinks.any((LinkItem l) => l.name == 'Atomic'), isTrue);
  });

  test('setVaultDirectory rewrites yaml to new directory and removes old artifacts', () async {
    await vault.load();
    final Directory newDir = await Directory.systemTemp.createTemp('portal_new_vault_');
    try {
      final File oldFile = File(vault.activeFilePath);
      expect(oldFile.existsSync(), isTrue);

      final bool moved = await vault.setVaultDirectory(newDir.path);
      expect(moved, isTrue);
      expect(vault.vaultDirectory, newDir.path);

      final File newFile = File(vault.activeFilePath);
      expect(newFile.existsSync(), isTrue);
      expect(oldFile.existsSync(), isFalse);

      expect(vault.allLinks.isNotEmpty, isTrue);
      expect(vault.categories.isNotEmpty, isTrue);

      const YamlCodec codec = YamlCodec();
      final PortalConfig parsed = codec.decode(await newFile.readAsString());
      expect(parsed.allLinks.isNotEmpty, isTrue);
      expect(parsed.allLinks.first.name, 'GitHub');
    } finally {
      if (newDir.existsSync()) {
        await newDir.delete(recursive: true);
      }
    }
  });

  test('setVaultDirectory rejects non-existent directory without touching old files', () async {
    await vault.load();
    final String oldPath = vault.activeFilePath;
    final File oldFile = File(oldPath);
    expect(oldFile.existsSync(), isTrue);

    final bool moved = await vault.setVaultDirectory('/non/existent/path/portal_12345');
    expect(moved, isFalse);
    expect(vault.vaultDirectory, tempDir.path);
    expect(oldFile.existsSync(), isTrue);
  });
}
