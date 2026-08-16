#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="XuXiake"
APP_VERSION="$(tr -d '[:space:]' <"$ROOT_DIR/VERSION")"
APP_BUILD_NUMBER="$(tr -d '[:space:]' <"$ROOT_DIR/BUILD_NUMBER")"
SOURCE_ARCHIVE="$ROOT_DIR/dist/release/$APP_NAME.zip"
TEST_RELEASE_DIR="$ROOT_DIR/dist/test"
TEST_RELEASE_NAME="$APP_NAME-$APP_VERSION-build.$APP_BUILD_NUMBER-macos-apple-silicon-test"
TEST_ARCHIVE="$TEST_RELEASE_DIR/$TEST_RELEASE_NAME.zip"
TEST_CHECKSUM="$TEST_ARCHIVE.sha256"
TEST_NOTES="$TEST_RELEASE_DIR/$TEST_RELEASE_NAME.md"

"$ROOT_DIR/script/build_release.sh"

mkdir -p "$TEST_RELEASE_DIR"
cp "$SOURCE_ARCHIVE" "$TEST_ARCHIVE"
cp "$ROOT_DIR/docs/test-release.md" "$TEST_NOTES"
(cd "$TEST_RELEASE_DIR" && shasum -a 256 "$(basename "$TEST_ARCHIVE")" >"$(basename "$TEST_CHECKSUM")")
(cd "$TEST_RELEASE_DIR" && shasum -a 256 -c "$(basename "$TEST_CHECKSUM")")
unzip -tqq "$TEST_ARCHIVE"

echo "Test archive: $TEST_ARCHIVE"
echo "Checksum: $TEST_CHECKSUM"
echo "Tester notes: $TEST_NOTES"
