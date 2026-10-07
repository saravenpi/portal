#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DEFAULT_DEST="${NUAGE:-${HOME}/Documents/NuagePersonal}"
DEST="$DEFAULT_DEST"

usage() {
  cat <<'EOF'
Usage: tool/build_apk.sh [--dest DIR]

  --dest DIR      Where to copy the universal APK. Defaults to $NUAGE or ~/Documents/NuagePersonal.
  -h, --help      This message.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dest)
      mkdir -p "$2"
      DEST="$(cd "$2" && pwd)"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

cd "$REPO_ROOT/app"

if ! command -v flutter >/dev/null 2>&1; then
  echo "error: flutter is not on PATH." >&2
  exit 1
fi

VERSION="$(sed -n 's/^version:[[:space:]]*\([^+]*\).*/\1/p' pubspec.yaml | head -1)"
if [ -z "$VERSION" ]; then
  echo "error: could not read version from pubspec.yaml" >&2
  exit 1
fi

if [ -f android/key.properties ]; then
  SIGNING="release keystore"
else
  SIGNING="DEBUG key (android/key.properties is missing)"
fi

echo "Portal Android Build (${VERSION})"
echo "  mode:    universal"
echo "  signing: ${SIGNING}"
echo "  dest:    ${DEST}"
echo

flutter build apk --release

SRC="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$SRC" ]; then
  echo "error: the build produced no APK at ${SRC}" >&2
  exit 1
fi

mkdir -p "$DEST"
TARGET="${DEST}/Portal-${VERSION}-universal.apk"
cp "$SRC" "$TARGET"

echo
echo "Copied to ${DEST}:"
size="$(du -h "$TARGET" | cut -f1)"
digest="$(sha256sum "$TARGET" | cut -c1-12)"
printf '  %-46s %6s  sha256:%s\n' "$(basename "$TARGET")" "$size" "$digest"
