# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
