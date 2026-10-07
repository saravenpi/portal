#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT/app"

DEFAULT_DEST="${NUAGE:-${HOME}/Documents/NuagePersonal}"
DEST="$DEFAULT_DEST"

usage() {
  cat <<'EOF'
Usage: tool/build_macos.sh [--dest DIR]

  --dest DIR      Where to copy the macOS artifacts. Defaults to $NUAGE or ~/Documents/NuagePersonal.
  -h, --help      This message.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dest) DEST="${2:?--dest needs a directory}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if ! command -v flutter >/dev/null 2>&1; then
  echo "error: flutter is not on PATH." >&2
  exit 1
fi

if [ "$(uname -s)" != "Darwin" ]; then
  echo "error: building macOS apps requires macOS." >&2
  exit 1
fi

VERSION="$(sed -n 's/^version:[[:space:]]*\([^+]*\).*/\1/p' pubspec.yaml | head -1)"
if [ -z "$VERSION" ]; then
  echo "error: could not read version from pubspec.yaml" >&2
  exit 1
fi

echo "Portal macOS Build (${VERSION})"
echo "  dest:    ${DEST}"
echo

flutter build macos --release

APP_SRC="build/macos/Build/Products/Release/portal.app"
APP_TARGET="build/macos/Build/Products/Release/Portal.app"
if [ -d "$APP_SRC" ] && [ ! -d "$APP_TARGET" ]; then
  cp -R "$APP_SRC" "$APP_TARGET"
fi
if [ -d "$APP_TARGET" ]; then
  APP_SRC="$APP_TARGET"
fi

if [ ! -d "$APP_SRC" ]; then
  echo "error: the build produced no app bundle in build/macos/Build/Products/Release/" >&2
  exit 1
fi

mkdir -p "$DEST"

ZIP_TARGET="${DEST}/Portal-${VERSION}-macos.zip"
ditto -c -k --sequesterRsrc --keepParent "$APP_SRC" "$ZIP_TARGET"

DMG_TARGET="${DEST}/Portal-${VERSION}-macos.dmg"
if command -v hdiutil >/dev/null 2>&1; then
  rm -f "$DMG_TARGET"
  hdiutil create -volname "Portal" -srcfolder "$APP_SRC" -ov -format UDZO "$DMG_TARGET" >/dev/null
fi

echo
echo "Copied to ${DEST}:"
for TARGET in "$DMG_TARGET" "$ZIP_TARGET"; do
  if [ -f "$TARGET" ]; then
    size="$(du -h "$TARGET" | cut -f1)"
    if command -v sha256sum >/dev/null 2>&1; then
      digest="$(sha256sum "$TARGET" | cut -c1-12)"
    else
      digest="$(shasum -a 256 "$TARGET" | cut -c1-12)"
    fi
    printf '  %-46s %6s  sha256:%s\n' "$(basename "$TARGET")" "$size" "$digest"
  fi
done
