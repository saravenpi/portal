# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2026-10-07

### Added
- Android adaptive icon implementation with full-bleed `#000000` background, safe-zone centered foreground, monochrome themed icon support, and round icon launcher resources.
- High-contrast `FaviconBadge` component with white background tile ensuring legibility for dark and transparent favicons.
- Horizontal swipe navigation across sections (links, categories, tags, settings) via `PageView`.

### Fixed
- Screen border collision on empty tags and categories screens with padding and text centering.

## [0.3.0] - 2026-10-07

### Added
- Rewrite and migrate YAML vault configuration on vault directory change without leaving old artifacts.
- Favicon display in link cards with network error fallback.
- Default to card display mode on mobile platforms.

### Fixed
- Inconsistent spacing and padding around bottom bar buttons in card display.

### Changed
- Standardized application display name to "Portal" across Android, desktop, and iOS.
- Updated application icon across Android, iOS, macOS, Windows, and Linux to a pixel art white circle ring with transparent interior on a solid black background.

## [0.2.0] - 2026-10-07

### Added
- Native Android/iOS share target integration via `receive_sharing_intent` to add shared links directly from the OS share sheet.
- Status bar edge-to-edge support with `SafeArea` layout protection and translucent system UI styling.
- Responsive button controls on narrow mobile screens.

### Removed
- Removed unused private links flag across CLI and Flutter application.

## [0.1.0] - 2026-10-07

### Added
- Cross-platform Flutter application (`app/`) matching the inverted Swiss typography and pixel art style of Cartes.
- Real-time filesystem synchronization with active `portal.yml` on local disk for concurrent use with CLI and Termux.
- 400ms debounced atomic writes to prevent file corruption.
- Forgiving YAML parser and canonical serializer in Dart (`YamlCodec`).
- Automatic OpenGraph metadata and favicon extraction on URL paste (`MetadataFetcher`).
- Instant fuzzy search across titles, URLs, descriptions, categories, and tags.
- Tagging catalog and category hierarchy with count badges.
- Compact list row and card grid view density modes.
- Dead link / HTTP reachability validator (`LinkValidator`).
- Monorepo structure containing `cli/` and `app/` orchestrated via root `Makefile` and `mise.toml`.
- `--version` flag in CLI.
