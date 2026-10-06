# portal

`portal` is a local-first links manager and static portal generator. It stores links in human-readable YAML files on disk and provides both a command-line tool and a cross-platform Flutter application styled after Cartes.

## Overview

The repository is a monorepo containing two workspaces:

1. `cli/`: A TypeScript command-line tool executed with Bun that parses forgiving YAML and compiles self-contained static `index.html` pages.
2. `app/`: A cross-platform Flutter application for desktop, mobile, and web. It features the inverted Swiss typographic aesthetic from Cartes, live filesystem synchronization, metadata scraping, and tagging.

Both tools share the same YAML format. You can edit your links file in a terminal editor, run the CLI, or use the Flutter app.

## Quick Start

### Toolchain Setup

Toolchains are pinned in `mise.toml`:

```bash
mise install
```

### Commands

Run commands from the repository root:

```bash
make cli-build    # Compile the CLI binary to cli/portal
make cli-test     # Run CLI smoke tests
make app-run      # Run the Flutter app in development mode
make app-test     # Run Flutter unit and widget tests
make app-analyze  # Run static analysis on the Flutter app
make test         # Run test suites for both CLI and app
```

## Workspaces

### CLI (`cli/`)

The CLI accepts forgiving YAML syntax and produces a single-file static HTML dashboard.

```bash
cd cli
bun run src/index.ts example.yml -o index.html
```

See [cli/README.md](file:///home/yann/Code/Saravenpi/portal/cli/README.md) and [SYNTAX.md](file:///home/yann/Code/Saravenpi/portal/SYNTAX.md) for full syntax details.

### Flutter App (`app/`)

The Flutter application provides a visual interface for managing links:

- **Style**: Inverted Swiss design on pure black canvas, 1px hairlines, zero rounded corners, single red accent (`#E5252A`), `undefined medium` monospace font, and `pixelarticons`.
- **Sync**: Watches the active `portal.yml` on disk. Changes made externally via Termux or text editors reload in the UI immediately. Changes made in the app write atomically to disk after a 400ms debounce.
- **Features**: Collections, tag filter chips, instant search, OpenGraph metadata extraction on paste, dead link checker, and desktop keyboard shortcuts.

```bash
cd app
flutter run -d linux
```

## Configuration Format

The canonical file format is documented in [SYNTAX.md](file:///home/yann/Code/Saravenpi/portal/SYNTAX.md) and demonstrated in [example.yml](file:///home/yann/Code/Saravenpi/portal/example.yml):

```yaml
title: Example Portal

Development:
  Docs: https://docs.example.com
  Dashboard: https://dashboard.example.com
  Repo:
    url: https://github.com/example/repo
    description: Official source code
    tags: [code, git]

categories:
  - category: Projects
    description: Active services
    links:
      - Admin: https://admin.example.com
      - Frontend: https://frontend.example.com
```

## License

MIT
