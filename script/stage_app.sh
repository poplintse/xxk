#!/usr/bin/env bash
set -euo pipefail

CONFIGURATION="${1:-debug}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="XuXiake"
BUNDLE_ID="com.iclawtse.xuxiake"
MIN_SYSTEM_VERSION="14.0"
VERSION_FILE="$ROOT_DIR/VERSION"
BUILD_NUMBER_FILE="$ROOT_DIR/BUILD_NUMBER"
APP_BUNDLE="${2:-$ROOT_DIR/dist/$APP_NAME.app}"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
ASSET_INFO="$ROOT_DIR/.build/asset-info.plist"

if [[ ! -f "$VERSION_FILE" || ! -f "$BUILD_NUMBER_FILE" ]]; then
  echo "VERSION and BUILD_NUMBER files are required" >&2
  exit 2
fi

APP_VERSION="$(tr -d '[:space:]' <"$VERSION_FILE")"
APP_BUILD_NUMBER="$(tr -d '[:space:]' <"$BUILD_NUMBER_FILE")"
if [[ ! "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "VERSION must contain three dot-separated integers, for example 1.0.0" >&2
  exit 2
fi
if [[ ! "$APP_BUILD_NUMBER" =~ ^[0-9]+([.][0-9]+){0,2}$ ]]; then
  echo "BUILD_NUMBER must contain one to three dot-separated integers" >&2
  exit 2
fi

case "$APP_BUNDLE" in
  "$ROOT_DIR"/dist/*.app|"$ROOT_DIR"/dist/*/*.app) ;;
  *)
    echo "output app must be inside $ROOT_DIR/dist and end in .app" >&2
    exit 2
    ;;
esac

case "$CONFIGURATION" in
  debug|release) ;;
  *)
    echo "usage: $0 [debug|release] [output.app]" >&2
    exit 2
    ;;
esac

BUILD_ARGUMENTS=(--package-path "$ROOT_DIR" --configuration "$CONFIGURATION")
if [[ "$CONFIGURATION" == "release" ]]; then
  BUILD_ARGUMENTS+=(--arch arm64)
fi
swift build "${BUILD_ARGUMENTS[@]}"
BUILD_BINARY="$(swift build "${BUILD_ARGUMENTS[@]}" --show-bin-path)/$APP_NAME"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

xcrun actool "$ROOT_DIR/Resources/Assets.xcassets" \
  --compile "$APP_RESOURCES" \
  --platform macosx \
  --minimum-deployment-target "$MIN_SYSTEM_VERSION" \
  --app-icon AppIcon \
  --output-partial-info-plist "$ASSET_INFO" >/dev/null

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>徐霞客</string>
  <key>CFBundleDisplayName</key>
  <string>徐霞客</string>
  <key>CFBundleShortVersionString</key>
  <string>$APP_VERSION</string>
  <key>CFBundleVersion</key>
  <string>$APP_BUILD_NUMBER</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIconName</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

plutil -lint "$INFO_PLIST" >/dev/null
echo "$APP_BUNDLE"
