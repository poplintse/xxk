#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_BUNDLE="$REPO_ROOT/dist/release/XuXiake.app"
ARCHIVE="$REPO_ROOT/dist/release/XuXiake.zip"
CHECKSUM="$ARCHIVE.sha256"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"

if [[ -z "$NOTARY_PROFILE" ]]; then
  echo "NOTARY_PROFILE must name a notarytool keychain profile" >&2
  exit 2
fi

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "Release app not found: $APP_BUNDLE" >&2
  exit 2
fi

if [[ ! -f "$ARCHIVE" || ! -f "$CHECKSUM" ]]; then
  echo "Release archive or checksum not found; run scripts/macos/build_release.sh first" >&2
  exit 2
fi

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
SIGNING_DETAILS="$(codesign -dvvv "$APP_BUNDLE" 2>&1)"
if grep -q '^Signature=adhoc$' <<<"$SIGNING_DETAILS"; then
  echo "Release app is ad-hoc signed; rebuild with SIGNING_IDENTITY set to a Developer ID Application identity" >&2
  exit 2
fi
if ! grep -q '^Authority=Developer ID Application:' <<<"$SIGNING_DETAILS"; then
  echo "Release app is not signed with a Developer ID Application identity" >&2
  exit 2
fi

"$REPO_ROOT/scripts/macos/verify_release.sh"

xcrun notarytool submit "$ARCHIVE" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$APP_BUNDLE"
xcrun stapler validate "$APP_BUNDLE"
spctl --assess --type execute --verbose=2 "$APP_BUNDLE"
rm -f "$ARCHIVE"
ditto -c -k --keepParent --norsrc --noextattr --noqtn --noacl "$APP_BUNDLE" "$ARCHIVE"
(cd "$(dirname "$ARCHIVE")" && shasum -a 256 "$(basename "$ARCHIVE")" >"$(basename "$ARCHIVE").sha256")
"$REPO_ROOT/scripts/macos/verify_release.sh"
