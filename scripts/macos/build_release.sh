#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MACOS_DIR="$REPO_ROOT/apps/macos"
APP_NAME="XuXiake"
RELEASE_DIR="$REPO_ROOT/dist/release"
APP_BUNDLE="$RELEASE_DIR/$APP_NAME.app"
ARCHIVE="$RELEASE_DIR/$APP_NAME.zip"
SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"

mkdir -p "$RELEASE_DIR"
"$REPO_ROOT/scripts/macos/stage_app.sh" release "$APP_BUNDLE"

SIGN_ARGUMENTS=(
  --force
  --options runtime
  --entitlements "$MACOS_DIR/Resources/XuXiake.entitlements"
  --sign "$SIGNING_IDENTITY"
)
if [[ "$SIGNING_IDENTITY" == "-" ]]; then
  SIGN_ARGUMENTS+=(--timestamp=none)
else
  SIGN_ARGUMENTS+=(--timestamp)
fi
codesign "${SIGN_ARGUMENTS[@]}" "$APP_BUNDLE"

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
rm -f "$ARCHIVE"
ditto -c -k --keepParent --norsrc --noextattr --noqtn --noacl "$APP_BUNDLE" "$ARCHIVE"
(cd "$RELEASE_DIR" && shasum -a 256 "$APP_NAME.zip" >"$APP_NAME.zip.sha256")
"$REPO_ROOT/scripts/macos/verify_release.sh"

echo "App: $APP_BUNDLE"
echo "Archive: $ARCHIVE"
echo "Checksum: $ARCHIVE.sha256"
