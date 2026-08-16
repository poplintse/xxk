#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="XuXiake"
BUNDLE_ID="com.iclawtse.xuxiake"
MIN_SYSTEM_VERSION="14.0"
APP_BUNDLE="$ROOT_DIR/dist/release/$APP_NAME.app"
ARCHIVE="$ROOT_DIR/dist/release/$APP_NAME.zip"
CHECKSUM="$ARCHIVE.sha256"
VERSION_FILE="$ROOT_DIR/VERSION"
BUILD_NUMBER_FILE="$ROOT_DIR/BUILD_NUMBER"

fail() {
  echo "Release verification failed: $*" >&2
  exit 2
}

for required_path in "$APP_BUNDLE" "$ARCHIVE" "$CHECKSUM" "$VERSION_FILE" "$BUILD_NUMBER_FILE"; do
  [[ -e "$required_path" ]] || fail "missing $required_path"
done

EXPECTED_VERSION="$(tr -d '[:space:]' <"$VERSION_FILE")"
EXPECTED_BUILD_NUMBER="$(tr -d '[:space:]' <"$BUILD_NUMBER_FILE")"

(cd "$(dirname "$ARCHIVE")" && shasum -a 256 -c "$(basename "$CHECKSUM")")
unzip -tqq "$ARCHIVE"
ARCHIVE_ENTRIES="$(zipinfo -1 "$ARCHIVE")"
if grep -Eqv "^$APP_NAME[.]app(/|$)" <<<"$ARCHIVE_ENTRIES"; then
  fail "archive contains entries outside $APP_NAME.app"
fi
if grep -Eq '/[.]_' <<<"$ARCHIVE_ENTRIES"; then
  fail "archive contains AppleDouble metadata"
fi

VERIFY_TMP_DIR="$(mktemp -d /private/tmp/xuxiake-release-verify.XXXXXX)"
trap 'rm -rf "$VERIFY_TMP_DIR"' EXIT
ditto -x -k "$ARCHIVE" "$VERIFY_TMP_DIR"
PACKAGED_APP="$VERIFY_TMP_DIR/$APP_NAME.app"
PACKAGED_INFO="$PACKAGED_APP/Contents/Info.plist"
PACKAGED_BINARY="$PACKAGED_APP/Contents/MacOS/$APP_NAME"

[[ -d "$PACKAGED_APP" && -f "$PACKAGED_INFO" && -x "$PACKAGED_BINARY" ]] || fail "archive has an invalid app bundle structure"
plutil -lint "$PACKAGED_INFO" >/dev/null

[[ "$(plutil -extract CFBundleIdentifier raw "$PACKAGED_INFO")" == "$BUNDLE_ID" ]] || fail "unexpected bundle identifier"
[[ "$(plutil -extract CFBundleShortVersionString raw "$PACKAGED_INFO")" == "$EXPECTED_VERSION" ]] || fail "app version does not match VERSION"
[[ "$(plutil -extract CFBundleVersion raw "$PACKAGED_INFO")" == "$EXPECTED_BUILD_NUMBER" ]] || fail "app build number does not match BUILD_NUMBER"
[[ "$(plutil -extract LSMinimumSystemVersion raw "$PACKAGED_INFO")" == "$MIN_SYSTEM_VERSION" ]] || fail "unexpected minimum system version"

ARCHITECTURES="$(lipo -archs "$PACKAGED_BINARY")"
[[ "$ARCHITECTURES" == "arm64" ]] || fail "expected an Apple Silicon arm64 binary, found: $ARCHITECTURES"
codesign --verify --deep --strict --verbose=2 "$PACKAGED_APP"
SIGNING_DETAILS="$(codesign -dvvv "$PACKAGED_APP" 2>&1)"
grep -q 'CodeDirectory .*runtime' <<<"$SIGNING_DETAILS" || fail "Hardened Runtime is not enabled"

SIGNED_ENTITLEMENTS="$(codesign -d --entitlements - "$PACKAGED_APP" 2>/dev/null)"
SANDBOX_ENTRY="$(grep -A2 '[[]Key[]] com.apple.security.app-sandbox' <<<"$SIGNED_ENTITLEMENTS" || true)"
grep -q '[[]Bool[]] true' <<<"$SANDBOX_ENTRY" || fail "App Sandbox is not enabled"

echo "Release verified: $APP_NAME $EXPECTED_VERSION ($EXPECTED_BUILD_NUMBER), Apple Silicon, sandboxed, Hardened Runtime"
