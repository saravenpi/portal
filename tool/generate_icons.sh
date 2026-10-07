#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

MAGICK_BIN=""
if command -v magick >/dev/null 2>&1; then
  MAGICK_BIN="magick"
elif command -v convert >/dev/null 2>&1; then
  MAGICK_BIN="convert"
else
  echo "error: ImageMagick (magick or convert) is required." >&2
  exit 1
fi

cat <<'EOF' > "$TMP_DIR/circle.pgm"
P2
32 32
255
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0
0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0 0 0 0 0 255 255 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
EOF

BASE_SOLID="$TMP_DIR/circle_solid.png"
BASE_FG="$TMP_DIR/circle_fg.png"

$MAGICK_BIN "$TMP_DIR/circle.pgm" "$BASE_SOLID"
$MAGICK_BIN "$BASE_SOLID" -transparent black "$BASE_FG"

echo "Generating Portal app icons (pixel circle on black)..."

# 1. Assets
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 512x512 app/assets/images/app_icon.png
$MAGICK_BIN "$BASE_FG" -filter point -resize 1080x1080 app/assets/images/app_icon_foreground.png

# 2. macOS appiconset
MACOS_SET="app/macos/Runner/Assets.xcassets/AppIcon.appiconset"
for SIZE in 16 32 64 128 256 512 1024; do
  $MAGICK_BIN "$BASE_SOLID" -filter point -resize "${SIZE}x${SIZE}" "${MACOS_SET}/app_icon_${SIZE}.png"
done

# 3. iOS appiconset
IOS_SET="app/ios/Runner/Assets.xcassets/AppIcon.appiconset"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 20x20 "${IOS_SET}/Icon-App-20x20@1x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 40x40 "${IOS_SET}/Icon-App-20x20@2x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 60x60 "${IOS_SET}/Icon-App-20x20@3x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 29x29 "${IOS_SET}/Icon-App-29x29@1x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 58x58 "${IOS_SET}/Icon-App-29x29@2x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 87x87 "${IOS_SET}/Icon-App-29x29@3x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 40x40 "${IOS_SET}/Icon-App-40x40@1x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 80x80 "${IOS_SET}/Icon-App-40x40@2x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 120x120 "${IOS_SET}/Icon-App-40x40@3x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 120x120 "${IOS_SET}/Icon-App-60x60@2x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 180x180 "${IOS_SET}/Icon-App-60x60@3x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 76x76 "${IOS_SET}/Icon-App-76x76@1x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 152x152 "${IOS_SET}/Icon-App-76x76@2x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 167x167 "${IOS_SET}/Icon-App-83.5x83.5@2x.png"
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 1024x1024 "${IOS_SET}/Icon-App-1024x1024@1x.png"

# 4. Android mipmaps
RES="app/android/app/src/main/res"
gen_android() {
  local DENSITY="$1"
  local LAUNCHER_SIZE="$2"
  local FG_SIZE="$3"
  local DIR="${RES}/mipmap-${DENSITY}"
  mkdir -p "$DIR"
  $MAGICK_BIN "$BASE_SOLID" -filter point -resize "${LAUNCHER_SIZE}x${LAUNCHER_SIZE}" "${DIR}/ic_launcher.png"
  $MAGICK_BIN "$BASE_SOLID" -filter point -resize "${LAUNCHER_SIZE}x${LAUNCHER_SIZE}" "${DIR}/ic_launcher_round.png"
  $MAGICK_BIN "$BASE_FG" -filter point -resize "${FG_SIZE}x${FG_SIZE}" "${DIR}/ic_launcher_foreground.png"
}

gen_android "mdpi" 48 108
gen_android "hdpi" 72 162
gen_android "xhdpi" 96 216
gen_android "xxhdpi" 144 324
gen_android "xxxhdpi" 192 432

# 5. Web icons
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 32x32 app/web/favicon.png
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 192x192 app/web/icons/Icon-192.png
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 512x512 app/web/icons/Icon-512.png
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 192x192 app/web/icons/Icon-maskable-192.png
$MAGICK_BIN "$BASE_SOLID" -filter point -resize 512x512 app/web/icons/Icon-maskable-512.png

# 6. Windows ico
$MAGICK_BIN "$BASE_SOLID" -filter point -define icon:auto-resize=256,128,64,48,32,16 app/windows/runner/resources/app_icon.ico

echo "All icons generated successfully!"
