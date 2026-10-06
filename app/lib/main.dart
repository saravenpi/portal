import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/storage/portal_vault.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String vaultPath = '';
  if (!kIsWeb) {
    try {
      final File localFile = File('portal.yml');
      if (localFile.existsSync()) {
        vaultPath = Directory.current.path;
      } else {
        final Directory docs = await getApplicationDocumentsDirectory();
        vaultPath = docs.path;
      }
    } catch (_) {
      try {
        final Directory docs = await getApplicationDocumentsDirectory();
        vaultPath = docs.path;
      } catch (_) {
        vaultPath = Directory.current.path;
      }
    }
  }

  final PortalVault vault = PortalVault(
    vaultDirectory: vaultPath.isNotEmpty ? vaultPath : null,
  );
  await vault.load();

  runApp(PortalApp(vault: vault));
}
