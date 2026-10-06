import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import '../../domain/models/category.dart';
import '../../domain/models/link_item.dart';
import '../../domain/models/portal_config.dart';
import '../../domain/services/link_validator.dart';
import '../codec/yaml_codec.dart';
import 'vault_watcher.dart';

class PortalVault extends ChangeNotifier {
  String _vaultDirectory;
  String _activeFileName;
  final YamlCodec _codec;
  final LinkValidator _linkValidator;

  PortalConfig _config;
  Timer? _debounceTimer;
  VaultWatcher? _watcher;
  String? _lastWrittenContent;

  PortalVault({
    String? vaultDirectory,
    this._activeFileName = 'portal.yml',
    this._codec = const YamlCodec(),
    this._linkValidator = const LinkValidator(),
    PortalConfig initialConfig = const PortalConfig(),
  })  : _vaultDirectory = vaultDirectory ?? Directory.current.path,
        _config = initialConfig;

  PortalConfig get config => _config;

  String get activeFilePath {
    if (_vaultDirectory.endsWith('/') || _vaultDirectory.endsWith('\\')) {
      return '$_vaultDirectory$_activeFileName';
    }
    return '$_vaultDirectory/$_activeFileName';
  }

  String get vaultDirectory => _vaultDirectory;

  bool get isWatching => _watcher?.isWatching ?? false;

  bool get isDirty => _debounceTimer?.isActive ?? false;

  List<Category> get categories => _config.categories;

  List<LinkItem> get allLinks => _config.allLinks;

  List<String> get allDistinctTags {
    final Set<String> tagSet = <String>{};
    for (final LinkItem link in allLinks) {
      tagSet.addAll(link.tags);
    }
    final List<String> sortedTags = tagSet.toList()..sort();
    return List<String>.unmodifiable(sortedTags);
  }

  Future<void> load({bool createIfMissing = true}) async {
    final File file = File(activeFilePath);
    if (!file.existsSync()) {
      if (createIfMissing) {
        const String initialYaml = 'title: Portal\n\nLinks:\n  - name: GitHub\n    url: https://github.com\n';
        final Directory dir = Directory(_vaultDirectory);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        await file.writeAsString(initialYaml, flush: true);
        _lastWrittenContent = initialYaml;
        _config = _codec.decode(initialYaml);
      } else {
        _config = const PortalConfig();
      }
    } else {
      final String content = await file.readAsString();
      _lastWrittenContent = content;
      _config = _codec.decode(content);
    }

    notifyListeners();
    await _restartWatcher();
  }

  bool _isWritableDirectory(Directory dir) {
    try {
      final File probe = File('${dir.path}/.portal_write_test_${DateTime.now().microsecondsSinceEpoch}');
      probe.writeAsStringSync('');
      probe.deleteSync();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setVaultDirectory(String path) async {
    final Directory newDir = Directory(path);
    if (!newDir.existsSync() || !_isWritableDirectory(newDir)) {
      return false;
    }

    if (path == _vaultDirectory) {
      return true;
    }

    await flush();

    final String oldFilePath = activeFilePath;
    final File oldFile = File(oldFilePath);
    final File oldTmpFile = File('$oldFilePath.tmp');

    if (_lastWrittenContent == null && oldFile.existsSync()) {
      try {
        final String content = await oldFile.readAsString();
        _config = _codec.decode(content);
      } catch (_) {}
    }

    _vaultDirectory = path;
    final String newFilePath = activeFilePath;

    final String encoded = _codec.encode(_config);
    final File newTmpFile = File('$newFilePath.tmp');
    await newTmpFile.writeAsString(encoded, flush: true);
    if (newTmpFile.existsSync()) {
      await newTmpFile.rename(newFilePath);
    } else {
      await File(newFilePath).writeAsString(encoded, flush: true);
    }
    _lastWrittenContent = encoded;

    if (oldFilePath != newFilePath) {
      if (oldFile.existsSync()) {
        try {
          oldFile.deleteSync();
        } catch (_) {}
      }
      if (oldTmpFile.existsSync()) {
        try {
          oldTmpFile.deleteSync();
        } catch (_) {}
      }
    }

    await _restartWatcher();
    notifyListeners();
    return true;
  }

  Future<void> setActiveFile(String fileName) async {
    await flush();
    _activeFileName = fileName;
    await _restartWatcher();
    await load();
  }

  Future<void> addLink({
    required String categoryId,
    required LinkItem link,
  }) async {
    final List<Category> updatedCategories = <Category>[];
    bool categoryFound = false;

    for (final Category cat in _config.categories) {
      if (cat.id == categoryId) {
        categoryFound = true;
        updatedCategories.add(
          cat.copyWith(links: <LinkItem>[...cat.links, link]),
        );
      } else {
        updatedCategories.add(cat);
      }
    }

    if (!categoryFound) {
      if (updatedCategories.isEmpty) {
        updatedCategories.add(
          Category(
            id: categoryId,
            name: categoryId,
            links: <LinkItem>[link],
          ),
        );
      } else {
        final Category first = updatedCategories.first;
        updatedCategories[0] = first.copyWith(
          links: <LinkItem>[...first.links, link],
        );
      }
    }

    _config = _config.copyWith(categories: updatedCategories);
    notifyListeners();
    _scheduleWrite();
  }

  Future<void> updateLink({
    required String categoryId,
    required LinkItem link,
  }) async {
    final List<Category> updatedCategories = <Category>[];

    for (final Category cat in _config.categories) {
      if (cat.id == categoryId) {
        final List<LinkItem> updatedLinks = cat.links.map((LinkItem existing) {
          return existing.id == link.id ? link : existing;
        }).toList();
        updatedCategories.add(cat.copyWith(links: updatedLinks));
      } else {
        updatedCategories.add(cat);
      }
    }

    _config = _config.copyWith(categories: updatedCategories);
    notifyListeners();
    _scheduleWrite();
  }

  Future<void> deleteLink({
    required String categoryId,
    required String linkId,
  }) async {
    final List<Category> updatedCategories = <Category>[];

    for (final Category cat in _config.categories) {
      if (cat.id == categoryId) {
        final List<LinkItem> updatedLinks = cat.links.where((LinkItem existing) {
          return existing.id != linkId;
        }).toList();
        updatedCategories.add(cat.copyWith(links: updatedLinks));
      } else {
        updatedCategories.add(cat);
      }
    }

    _config = _config.copyWith(categories: updatedCategories);
    notifyListeners();
    _scheduleWrite();
  }

  Future<void> moveLink({
    required String linkId,
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    if (fromCategoryId == toCategoryId) return;

    LinkItem? targetLink;
    final List<Category> updatedCategories = <Category>[];

    for (final Category cat in _config.categories) {
      if (cat.id == fromCategoryId) {
        final List<LinkItem> remainingLinks = <LinkItem>[];
        for (final LinkItem l in cat.links) {
          if (l.id == linkId) {
            targetLink = l;
          } else {
            remainingLinks.add(l);
          }
        }
        updatedCategories.add(cat.copyWith(links: remainingLinks));
      } else {
        updatedCategories.add(cat);
      }
    }

    if (targetLink == null) return;

    final List<Category> finalCategories = <Category>[];
    for (final Category cat in updatedCategories) {
      if (cat.id == toCategoryId) {
        finalCategories.add(
          cat.copyWith(links: <LinkItem>[...cat.links, targetLink]),
        );
      } else {
        finalCategories.add(cat);
      }
    }

    _config = _config.copyWith(categories: finalCategories);
    notifyListeners();
    _scheduleWrite();
  }

  Future<void> addCategory(Category category) async {
    _config = _config.copyWith(
      categories: <Category>[..._config.categories, category],
    );
    notifyListeners();
    _scheduleWrite();
  }

  Future<void> updateCategory(Category category) async {
    final List<Category> updatedCategories = _config.categories.map((Category cat) {
      return cat.id == category.id ? category : cat;
    }).toList();

    _config = _config.copyWith(categories: updatedCategories);
    notifyListeners();
    _scheduleWrite();
  }

  Future<void> deleteCategory(String categoryId) async {
    final List<Category> updatedCategories = _config.categories.where((Category cat) {
      return cat.id != categoryId;
    }).toList();

    _config = _config.copyWith(categories: updatedCategories);
    notifyListeners();
    _scheduleWrite();
  }

  Future<void> toggleFavorite({
    required String categoryId,
    required String linkId,
  }) async {
    final List<Category> updatedCategories = <Category>[];

    for (final Category cat in _config.categories) {
      if (cat.id == categoryId) {
        final List<LinkItem> updatedLinks = cat.links.map((LinkItem existing) {
          if (existing.id == linkId) {
            return existing.copyWith(isFavorite: !existing.isFavorite);
          }
          return existing;
        }).toList();
        updatedCategories.add(cat.copyWith(links: updatedLinks));
      } else {
        updatedCategories.add(cat);
      }
    }

    _config = _config.copyWith(categories: updatedCategories);
    notifyListeners();
    _scheduleWrite();
  }

  Future<void> validateAllLinks() async {
    final List<Category> updatedCategories = <Category>[];

    for (final Category cat in _config.categories) {
      final List<LinkItem> updatedLinks = <LinkItem>[];
      for (final LinkItem link in cat.links) {
        final LinkHealth health = await _linkValidator.checkHealth(link.url);
        updatedLinks.add(link.copyWith(health: health));
      }
      updatedCategories.add(cat.copyWith(links: updatedLinks));
    }

    _config = _config.copyWith(categories: updatedCategories);
    notifyListeners();
    _scheduleWrite();
  }

  Future<String> exportHtml() async {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="utf-8">');
    buffer.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1">');
    buffer.writeln('  <title>${_escapeHtml(_config.title)}</title>');
    buffer.writeln('  <style>');
    buffer.writeln('    body { background: #000; color: #fff; font-family: monospace; padding: 2rem; margin: 0; }');
    buffer.writeln('    h1 { color: #fff; border-bottom: 1px solid #262626; padding-bottom: 0.5rem; }');
    buffer.writeln('    h2 { color: #e5252a; margin-top: 2rem; font-size: 1.1rem; }');
    buffer.writeln('    ul { list-style: none; padding: 0; }');
    buffer.writeln('    li { margin: 0.5rem 0; }');
    buffer.writeln('    a { color: #fff; text-decoration: none; }');
    buffer.writeln('    a:hover { color: #e5252a; text-decoration: underline; }');
    buffer.writeln('    .desc { color: #9a9a9a; font-size: 0.85rem; margin-left: 0.5rem; }');
    buffer.writeln('    .tags { color: #5a5a5a; font-size: 0.75rem; margin-left: 0.5rem; }');
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <h1>${_escapeHtml(_config.title)}</h1>');

    for (final Category cat in _config.categories) {
      buffer.writeln('  <h2>${_escapeHtml(cat.name)}</h2>');
      if (cat.description != null && cat.description!.isNotEmpty) {
        buffer.writeln('  <p class="desc">${_escapeHtml(cat.description!)}</p>');
      }
      buffer.writeln('  <ul>');
      for (final LinkItem link in cat.links) {
        buffer.writeln('    <li>');
        buffer.writeln('      <a href="${_escapeHtml(link.url)}" target="_blank" rel="noopener">${_escapeHtml(link.name)}</a>');
        if (link.description != null && link.description!.isNotEmpty) {
          buffer.writeln('      <span class="desc">${_escapeHtml(link.description!)}</span>');
        }
        if (link.tags.isNotEmpty) {
          buffer.writeln('      <span class="tags">[${_escapeHtml(link.tags.join(', '))}]</span>');
        }
        buffer.writeln('    </li>');
      }
      buffer.writeln('  </ul>');
    }

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    final String html = buffer.toString();
    try {
      final File outFile = File('$_vaultDirectory/index.html');
      await outFile.writeAsString(html, flush: true);
    } catch (_) {}

    return html;
  }

  Future<void> flush() async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
      _debounceTimer = null;
      await _writeAtomic();
    }
  }

  void _scheduleWrite() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), _writeAtomic);
  }

  Future<void> _writeAtomic() async {
    final String targetPath = activeFilePath;
    final String encoded = _codec.encode(_config);
    _lastWrittenContent = encoded;

    final Directory dir = Directory(_vaultDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final File tmpFile = File('$targetPath.tmp');
    await tmpFile.writeAsString(encoded, flush: true);
    if (tmpFile.existsSync()) {
      await tmpFile.rename(targetPath);
    }
  }

  Future<void> _restartWatcher() async {
    if (_watcher != null) {
      await _watcher!.stop();
      _watcher = null;
    }

    final File file = File(activeFilePath);
    if (file.existsSync()) {
      _watcher = VaultWatcher(
        filePath: activeFilePath,
        onFileChanged: _onExternalFileChanged,
      );
      await _watcher!.start();
    }
  }

  Future<void> _onExternalFileChanged() async {
    final File file = File(activeFilePath);
    if (!file.existsSync()) return;

    try {
      final String content = await file.readAsString();
      if (content == _lastWrittenContent) {
        return;
      }
      _lastWrittenContent = content;
      final PortalConfig parsed = _codec.decode(content);
      _config = parsed;
      notifyListeners();
    } catch (_) {}
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  @override
  void dispose() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
      _writeAtomic();
    }
    _watcher?.dispose();
    super.dispose();
  }
}
