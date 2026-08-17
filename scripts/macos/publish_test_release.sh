#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MACOS_DIR="$REPO_ROOT/apps/macos"
APP_NAME="XuXiake"
APP_VERSION="$(tr -d '[:space:]' <"$MACOS_DIR/VERSION")"
APP_BUILD_NUMBER="$(tr -d '[:space:]' <"$MACOS_DIR/BUILD_NUMBER")"
SOURCE_ARCHIVE="$REPO_ROOT/dist/release/$APP_NAME.zip"
TEST_RELEASE_DIR="$REPO_ROOT/dist/test"
TEST_RELEASE_NAME="$APP_NAME-$APP_VERSION-build.$APP_BUILD_NUMBER-macos-apple-silicon-test"
TEST_ARCHIVE="$TEST_RELEASE_DIR/$TEST_RELEASE_NAME.zip"
TEST_CHECKSUM="$TEST_ARCHIVE.sha256"
TEST_NOTES="$TEST_RELEASE_DIR/$TEST_RELEASE_NAME.md"

"$REPO_ROOT/scripts/macos/build_release.sh"

mkdir -p "$TEST_RELEASE_DIR"
cp "$SOURCE_ARCHIVE" "$TEST_ARCHIVE"
cp "$REPO_ROOT/docs/test-release.md" "$TEST_NOTES"
(cd "$TEST_RELEASE_DIR" && shasum -a 256 "$(basename "$TEST_ARCHIVE")" >"$(basename "$TEST_CHECKSUM")")
(cd "$TEST_RELEASE_DIR" && shasum -a 256 -c "$(basename "$TEST_CHECKSUM")")
unzip -tqq "$TEST_ARCHIVE"

echo "Test archive: $TEST_ARCHIVE"
echo "Checksum: $TEST_CHECKSUM"
echo "Tester notes: $TEST_NOTES"
