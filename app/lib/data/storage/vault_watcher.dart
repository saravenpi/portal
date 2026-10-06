import 'dart:async';
import 'dart:io';
import 'package:watcher/watcher.dart';

class VaultWatcher {
  final String filePath;
  final void Function() onFileChanged;
  StreamSubscription<WatchEvent>? _subscription;
  bool _isWatching = false;

  VaultWatcher({
    required this.filePath,
    required this.onFileChanged,
  });

  bool get isWatching => _isWatching;

  Future<void> start() async {
    await stop();

    final File file = File(filePath);
    if (!file.existsSync()) {
      return;
    }

    try {
      final FileWatcher watcher = FileWatcher(filePath);
      _subscription = watcher.events.listen(
        (WatchEvent event) {
          if (event.type == ChangeType.MODIFY ||
              event.type == ChangeType.ADD) {
            onFileChanged();
          }
        },
        onError: (Object error) {
          _isWatching = false;
        },
      );
      _isWatching = true;
    } catch (_) {
      _isWatching = false;
    }
  }

  Future<void> stop() async {
    if (_subscription != null) {
      await _subscription!.cancel();
      _subscription = null;
    }
    _isWatching = false;
  }

  Future<void> dispose() async {
    await stop();
  }
}
