import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal/app.dart';
import 'package:portal/data/storage/portal_vault.dart';
import 'package:portal/domain/models/category.dart';
import 'package:portal/domain/models/link_item.dart';
import 'package:portal/domain/models/portal_config.dart';
import 'package:portal/features/links/presentation/links_view_model.dart';

void main() {
  late Directory tempDir;
  late PortalVault vault;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('portal_test_');
    vault = PortalVault(
      vaultDirectory: tempDir.path,
      activeFileName: 'portal.yml',
      initialConfig: const PortalConfig(
        title: 'Test Portal',
        categories: <Category>[
          Category(
            id: 'cat_dev',
            name: 'Development',
            links: <LinkItem>[
              LinkItem(
                id: 'link_github',
                name: 'GitHub',
                url: 'https://github.com',
                tags: <String>['code', 'git'],
                isFavorite: true,
              ),
              LinkItem(
                id: 'link_dart',
                name: 'Dart',
                url: 'https://dart.dev',
                tags: <String>['code', 'lang'],
              ),
            ],
          ),
          Category(
            id: 'cat_docs',
            name: 'Documentation',
            links: <LinkItem>[
              LinkItem(
                id: 'link_flutter',
                name: 'Flutter Docs',
                url: 'https://docs.flutter.dev',
                tags: <String>['docs'],
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

  testWidgets('AppShell renders sidebar and links view on wide layout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(PortalApp(vault: vault));
    await tester.pumpAndSettle();

    expect(find.text('PORTAL'), findsOneWidget);
    expect(find.text('LINKS'), findsWidgets);
    expect(find.text('CATEGORIES'), findsWidgets);
    expect(find.text('TAGS'), findsWidgets);
    expect(find.text('SETTINGS'), findsWidgets);

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Flutter Docs'), findsOneWidget);
  });

  testWidgets('AppShell navigates between destinations on wide layout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(PortalApp(vault: vault));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'CATEGORIES').first);
    await tester.pumpAndSettle();

    expect(find.text('2 CATEGORIES'), findsOneWidget);
    expect(find.text('DEVELOPMENT'), findsWidgets);
    expect(find.text('DOCUMENTATION'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'TAGS').first);
    await tester.pumpAndSettle();

    expect(find.text('4 TAGS'), findsOneWidget);
    expect(find.text('#code'), findsOneWidget);
    expect(find.text('#git'), findsOneWidget);
    expect(find.text('#lang'), findsOneWidget);
    expect(find.text('#docs'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'SETTINGS').first);
    await tester.pumpAndSettle();

    expect(find.text('LOCAL VAULT AND FILE CONFIGURATION'), findsOneWidget);
    expect(find.text('PORTAL v0.4.0'), findsOneWidget);
  });

  testWidgets('AppShell renders bottom bar on narrow layout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(PortalApp(vault: vault));
    await tester.pumpAndSettle();

    expect(find.byType(BottomAppBar), findsNothing);
    expect(find.text('LINKS'), findsWidgets);
    expect(find.text('CATEGORIES'), findsWidgets);
    expect(find.text('TAGS'), findsWidgets);
    expect(find.text('SETTINGS'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'CATEGORIES').first);
    await tester.pumpAndSettle();

    expect(find.text('2 CATEGORIES'), findsOneWidget);
  });

  testWidgets('LinksView search filter updates list',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(PortalApp(vault: vault));
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Flutter Docs'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'flutter');
    await tester.pumpAndSettle();

    expect(find.text('Flutter Docs'), findsOneWidget);
    expect(find.text('GitHub'), findsNothing);
  });

  testWidgets('LinksView density toggle switches between list and cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(PortalApp(vault: vault));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(GridView), findsNothing);

    await tester.tap(find.byTooltip('GRID VIEW'));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.byTooltip('LIST VIEW'));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
  });

  test('LinksViewModel initializes with card view when requested or on mobile', () {
    final LinksViewModel vmMobile = LinksViewModel(
      vault: vault,
      initialCardView: true,
    );
    expect(vmMobile.isCardView, isTrue);

    final LinksViewModel vmDesktop = LinksViewModel(
      vault: vault,
      initialCardView: false,
    );
    expect(vmDesktop.isCardView, isFalse);
  });

  testWidgets('AppShell allows swiping left and right between sections',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(PortalApp(vault: vault));
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 CATEGORIES'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('4 TAGS'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 CATEGORIES'), findsOneWidget);
  });
}
