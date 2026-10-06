# Portal Monorepo & Flutter App: Master Implementation Plan

This master plan details the architecture, design tokens, data formats, component hierarchy, and execution roadmap for transforming `portal` into a monorepo featuring the CLI and a cross-platform Flutter application styled after `Cartes`.

---

## 1. Executive Summary

- **Repository**: Monorepo containing `cli/` (TypeScript / Bun) and `app/` (Flutter).
- **Format**: Local-first YAML file (`portal.yml` or `*.portal.yml`) in a configurable vault directory.
- **Interoperability**: The Flutter app monitors the YAML file via live filesystem watching. Changes made via CLI, Vim, or Termux reload in the app in real time; changes made in the app write atomically to disk after a 400ms debounce.
- **Visual Aesthetic**: Exact fidelity to the inverted Swiss minimalism of `Cartes` — black canvas (`#000000`), deep surfaces (`#0A0A0A`, `#161616`), 1px hairlines (`#262626`), Swiss red accent (`#E5252A`), `undefined medium` monospace typography, and `pixelarticons`.
- **Feature Set**: Collections/categories, tagging with filter chips, instant search, OpenGraph metadata extraction, dead link checker, private links vault, and desktop keyboard shortcuts.

---

## 2. Monorepo Directory Tree

```
portal/
├── Makefile                     # Root build and test orchestration
├── mise.toml                    # Toolchain pinning: Flutter 3.47.6, Bun 1.4.2, Java 21
├── example.yml                  # Reference YAML file
├── SYNTAX.md                    # Permissive YAML specification
├── PLAN.md                      # This master plan
├── README.md                    # Monorepo documentation
│
├── cli/                         # Command-line interface workspace
│   ├── package.json
│   ├── bun.lock
│   ├── tsconfig.json
│   ├── Makefile
│   ├── install.sh
│   ├── src/
│   │   ├── index.ts             # Entry point
│   │   ├── cli.ts               # Argument parsing
│   │   ├── render.ts            # HTML generator
│   │   ├── constants.ts
│   │   ├── types.ts
│   │   ├── helpers.ts
│   │   └── parser/              # Category and link parsers
│   └── tests/
│       ├── smoke.sh             # Smoke test runner
│       └── fixtures/            # Valid and invalid test fixtures
│
└── app/                         # Flutter multi-platform workspace
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── assets/
    │   ├── fonts/
    │   │   ├── undefined-medium.ttf
    │   │   └── pixelart-icons.ttf
    │   └── images/
    │       ├── app_icon.png
    │       └── app_icon_foreground.png
    ├── test/
    │   ├── domain_test.dart
    │   ├── yaml_codec_test.dart
    │   ├── vault_test.dart
    │   └── widget_test.dart
    └── lib/
        ├── main.dart
        ├── app.dart
        ├── core/
        │   ├── theme/
        │   │   ├── app_colors.dart
        │   │   ├── app_dimens.dart
        │   │   ├── app_typography.dart
        │   │   └── app_theme.dart
        │   ├── ui/
        │   │   ├── pixel_icons.dart
        │   │   └── widgets/
        │   │       ├── pixel_button.dart
        │   │       ├── pixel_text_field.dart
        │   │       ├── layout_primitives.dart
        │   │       └── app_dialog.dart
        │   └── utils/
        │       ├── url_utils.dart
        │       └── date_utils.dart
        ├── domain/
        │   ├── models/
        │   │   ├── link_item.dart
        │   │   ├── category.dart
        │   │   ├── portal_config.dart
        │   │   └── link_filter.dart
        │   └── services/
        │       ├── metadata_fetcher.dart
        │       └── link_validator.dart
        ├── data/
        │   ├── codec/
        │   │   └── yaml_codec.dart
        │   └── storage/
        │       ├── portal_vault.dart
        │       └── vault_watcher.dart
        └── features/
            ├── shell/
            │   └── presentation/
            │       └── app_shell.dart
            ├── links/
            │   └── presentation/
            │       ├── links_view.dart
            │       ├── links_view_model.dart
            │       └── widgets/
            │           ├── link_row.dart
            │           ├── link_card.dart
            │           ├── link_editor_dialog.dart
            │           └── search_filter_bar.dart
            ├── categories/
            │   └── presentation/
            │       └── categories_view.dart
            ├── tags/
            │   └── presentation/
            │       └── tags_view.dart
            └── settings/
                └── presentation/
                    └── settings_view.dart
```

---

## 3. Data Specification & YAML Grammar

### Data Models

```dart
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
  final LinkHealth health; // unknown, healthy, broken
}

class Category {
  final String id;
  final String name;
  final String? description;
  final List<LinkItem> links;
}

class PortalConfig {
  final String title;
  final List<Category> categories;
}
```

### Forgiving Parsing Rules (from `SYNTAX.md`)

1. **Root-Level Categories & Direct Links**:
   ```yaml
   title: Personal Portal

   GitHub: https://github.com
   Docs:
     url: https://docs.example.com
     description: Documentation
     tags: [dev]

   Development:
     - Repo: https://github.com/example/repo
     - Dashboard -> https://dash.example.com
   ```
2. **Explicit Categories Container**:
   ```yaml
   categories:
     - category: Operations
       description: Production systems
       links:
         - Grafana: https://grafana.com
   ```
3. **Map-Style Categories**:
   ```yaml
   categories:
     Design:
       Figma: https://figma.com
   ```
4. **Shorthand Links**:
   - `Name: https://...`
   - `Name -> https://...`
   - `Name => https://...`
   - `Name | https://...`
   - `https://...` (name derived from domain)

### Canonical Serializer

When saving back to disk from the Flutter app, the serializer produces clean, formatted YAML:
- File header `title: ...`
- Top-level named categories with their links.
- Rich links with `description`, `tags`, `private`, `favorite`.
- Atomic file write: writes `portal.yml.tmp`, syncs, and renames to `portal.yml`.

---

## 4. UI / UX Design & Component Hierarchy

### Styling Invariants (Cartes Parity)

- **Palette**:
  - `background`: `#000000`
  - `surface`: `#0A0A0A`
  - `surfaceRaised`: `#161616`
  - `rule`: `#262626`
  - `ruleStrong`: `#6B6B6B`
  - `textPrimary`: `#FFFFFF`
  - `textSecondary`: `#9A9A9A`
  - `textTertiary`: `#5A5A5A`
  - `accent`: `#E5252A`
- **Corners**: `BorderRadius.zero` (`AppRadii.none`) everywhere.
- **Shadows**: None. Depth is drawn with 1px `AppColors.rule` borders.
- **Font**: `UndefinedMedium` monospace. Uppercase letterspaced labels for buttons, headers, and overlines.
- **Icons**: `Pixelarticons` font via `PixelIcons`.

### Shell & Navigation

- **Desktop (width >= 900px)**:
  - Fixed 224px sidebar on left:
    - Wordmark: `PORTAL` with pixelart bookmark/portal glyph.
    - Destinations:
      - `LINKS`: all links with total count badge.
      - `CATEGORIES`: category tree with count badges.
      - `TAGS`: tag catalog.
      - `FAVORITES`: starred items.
      - `SETTINGS`: storage path, dead-link checker, HTML exporter.
    - Vault status chip: active file (`portal.yml`) + live watch status.
- **Mobile (width < 900px)**:
  - Bottom bar with `LINKS`, `CATEGORIES`, `TAGS`, `SETTINGS`.
  - Top header with search action and quick-add button.

### Link Management Interface

- **Search & Filter Bar**:
  - Instant text filter matching name, URL, tags, description.
  - Active filter chips (category filter, tag filter, favorites-only toggle, private toggle).
  - Density toggle: compact single-line rows vs. rich cards.
- **Link Editor Dialog**:
  - URL input with automatic background metadata resolution (`MetadataFetcher`).
  - Auto-fills page title, description, and favicon.
  - Category picker dropdown and comma-separated tags input.
  - Private and favorite toggles.
- **Keyboard Shortcuts (Desktop)**:
  - `/`: focus search.
  - `n`: open new link dialog.
  - `c`: open new category dialog.
  - `j` / `k` or `ArrowDown` / `ArrowUp`: navigate list items.
  - `Enter` or `o`: launch URL in browser.
  - `y`: copy URL to clipboard.
  - `e`: edit selected link.
  - `d`: delete selected link.

---

## 5. Parallel Subagents Execution Strategy

We deploy three specialized parallel subagents running concurrently:

### Subagent 1: Domain & Data Engine (`data-engine`)
- **Scope**:
  - `domain/models/`: `LinkItem`, `Category`, `PortalConfig`, `LinkFilter`.
  - `data/codec/yaml_codec.dart`: permissive YAML parser and canonical YAML generator.
  - `data/storage/portal_vault.dart`: file system operations, atomic debounced writes, fallback template generation.
  - `data/storage/vault_watcher.dart`: live file watcher monitoring external updates.
  - `domain/services/metadata_fetcher.dart`: OpenGraph / favicon scraper.
  - `domain/services/link_validator.dart`: HTTP HEAD/GET dead link checker.
  - Unit tests in `test/yaml_codec_test.dart` and `test/vault_test.dart`.

### Subagent 2: Features, UI Screens & State (`ui-features`)
- **Scope**:
  - `features/shell/presentation/app_shell.dart`: responsive sidebar / bottom bar shell.
  - `features/links/presentation/`: `LinksViewModel`, `LinksView`, `LinkRow`, `LinkCard`, `SearchFilterBar`.
  - `features/links/presentation/widgets/link_editor_dialog.dart`: add/edit modal with live metadata scraping.
  - `features/categories/presentation/categories_view.dart`: category manager and link filter.
  - `features/tags/presentation/tags_view.dart`: tag explorer and filter chips.
  - `features/settings/presentation/settings_view.dart`: vault directory selector, portal file switcher, link health inspector, HTML generator button.
  - `app/lib/app.dart`: root widget wiring ChangeNotifierProvider.

### Subagent 3: Monorepo Integration, Quality Gate & Verification (`qa-verifier`)
- **Scope**:
  - CLI integration: verify `cli/` tests, ensure `example.yml` works with both CLI and Flutter app.
  - Desktop keyboard shortcut handler wiring.
  - Run `flutter analyze` and resolve all strict linting errors.
  - Run `flutter test` across all unit and widget tests.
  - Verify `make test` and `make build` pass cleanly.

---

## 6. Verification Criteria

1. `make cli-test` exits 0 (all smoke fixtures pass).
2. `make app-test` exits 0 (all unit and widget tests pass).
3. `make app-analyze` exits 0 (strict linter passes with zero warnings).
4. Full interoperability verified: editing `portal.yml` manually or with CLI triggers instant UI updates, and saving in the app writes clean, valid YAML.
