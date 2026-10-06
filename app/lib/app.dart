import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/storage/portal_vault.dart';
import 'features/links/presentation/links_view_model.dart';
import 'features/shell/presentation/app_shell.dart';

class PortalApp extends StatefulWidget {
  const PortalApp({
    super.key,
    required this.vault,
  });

  final PortalVault vault;

  @override
  State<PortalApp> createState() => _PortalAppState();
}

class _PortalAppState extends State<PortalApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onInactive: _flush,
      onHide: _flush,
      onPause: _flush,
      onDetach: _flush,
    );
  }

  void _flush() {
    widget.vault.flush().catchError((Object _) {});
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortalVault>.value(value: widget.vault),
        ChangeNotifierProxyProvider<PortalVault, LinksViewModel>(
          create: (BuildContext ctx) =>
              LinksViewModel(vault: ctx.read<PortalVault>()),
          update: (BuildContext ctx, PortalVault vault, LinksViewModel? prev) =>
              prev ?? LinksViewModel(vault: vault),
        ),
      ],
      child: MaterialApp(
        title: 'Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        builder: (BuildContext context, Widget? child) {
          final MediaQueryData media = MediaQuery.of(context);
          final double scale = media.textScaler.scale(16) / 16;
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(scale.clamp(1.0, 1.4)),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const AppShell(),
      ),
    );
  }
}
