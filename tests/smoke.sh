#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
VALID_DIR="$ROOT_DIR/tests/fixtures/valid"
INVALID_DIR="$ROOT_DIR/tests/fixtures/invalid"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

for fixture in "$VALID_DIR"/*.yml; do
  out_file="$TMP_DIR/$(basename "$fixture" .yml).html"
  bun run "$ROOT_DIR/src/index.ts" "$fixture" -o "$out_file" >/dev/null
  test -s "$out_file"
done

for fixture in "$INVALID_DIR"/*.yml; do
  if bun run "$ROOT_DIR/src/index.ts" "$fixture" -o "$TMP_DIR/invalid.html" >"$TMP_DIR/error.log" 2>&1; then
    echo "Expected failure for $fixture"
    exit 1
  fi

  grep -q "Invalid portal file" "$TMP_DIR/error.log"
done

echo "smoke tests passed"
