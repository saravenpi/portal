#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT/app"

DEFAULT_DEST="${NUAGE:-${HOME}/Documents/NuagePersonal}"
DEST="$DEFAULT_DEST"
MODE="universal"

usage() {
  cat <<'EOF'
Usage: tool/build_apk.sh [--split-per-abi] [--dest DIR]

  --split-per-abi Build one APK per ABI instead of the default universal build.
  --dest DIR      Where to copy the result. Defaults to $NUAGE or ~/Documents/NuagePersonal.
  -h, --help      This message.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --split-per-abi) MODE="split"; shift ;;
    --dest) DEST="${2:?--dest needs a directory}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

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
echo "  mode:    ${MODE}"
echo "  signing: ${SIGNING}"
echo "  dest:    ${DEST}"
echo

if [ "$MODE" = "universal" ]; then
  flutter build apk --release
else
  flutter build apk --release --split-per-abi
fi

OUT_DIR="build/app/outputs/flutter-apk"
mkdir -p "$DEST"

copied=()
if [ "$MODE" = "universal" ]; then
  sources=("$OUT_DIR/app-release.apk")
else
  sources=("$OUT_DIR"/app-*-release.apk)
fi

for src in "${sources[@]}"; do
  [ -f "$src" ] || continue

  base="$(basename "$src")"
  abi="$(printf '%s' "$base" | sed -n 's/^app-\(.*\)-release\.apk$/\1/p')"
  [ -n "$abi" ] || abi="universal"

  target="${DEST}/Portal-${VERSION}-${abi}.apk"
  cp "$src" "$target"
  copied+=("$target")
done

if [ ${#copied[@]} -eq 0 ]; then
  echo "error: the build produced no APKs in ${OUT_DIR}" >&2
  exit 1
fi

echo
echo "Copied to ${DEST}:"
for target in "${copied[@]}"; do
  size="$(du -h "$target" | cut -f1)"
  digest="$(sha256sum "$target" | cut -c1-12)"
  printf '  %-46s %6s  sha256:%s\n' "$(basename "$target")" "$size" "$digest"
done
