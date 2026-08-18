#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=build-common.sh
source "$SCRIPT_DIR/build-common.sh"

readonly APP_NAME="XuXiake"
readonly MACOS_DIR="$BUILD_ROOT/apps/macos"
requested_version="${VERSION:-${1:-}}"
create_build_log macos debug

source_version="$(read_single_line "$MACOS_DIR/VERSION")"
source_build="$(read_single_line "$MACOS_DIR/BUILD_NUMBER")"
if ! is_semver "$source_version"; then
  fail_build "macOS Debug" "invalid apps/macos/VERSION: $source_version" 2
fi
if [[ ! "$source_build" =~ ^[1-9][0-9]*$ ]]; then
  fail_build "macOS Debug" "invalid apps/macos/BUILD_NUMBER: $source_build" 2
fi
if [[ -n "$requested_version" ]] && ! is_semver "$requested_version"; then
  fail_build "macOS Debug" "invalid VERSION: $requested_version" 2
fi
if [[ -n "$requested_version" && "$requested_version" != "$source_version" ]]; then
  fail_build "macOS Debug" "VERSION=$requested_version does not match apps/macos/VERSION=$source_version" 2
fi
if [[ -n "${BUILD_NUMBER:-}" ]]; then
  fail_build "macOS Debug" "BUILD_NUMBER is assigned automatically; use make set-macos-build-number only to reset its base" 2
fi

version="$source_version"
if ! acquire_macos_build_lock; then
  fail_build "macOS Debug" "another macOS build is already assigning a build number"
fi
trap release_macos_build_lock EXIT HUP INT TERM

build_number="$(next_macos_build_number "$source_build")"
artifact_dir="$BUILD_ROOT/artifacts/macos/$version"
artifact="$artifact_dir/$APP_NAME-debug-$build_number.app"
mkdir -p "$artifact_dir"

if ! (
  APP_VERSION_OVERRIDE="$version" \
  APP_BUILD_NUMBER_OVERRIDE="$build_number" \
    "$BUILD_ROOT/scripts/macos/stage_app.sh" debug "$artifact"
  codesign --force --sign - "$artifact"
  codesign --verify --deep --strict --verbose=2 "$artifact"
  "$BUILD_ROOT/scripts/verify-artifact.sh" macos "$version" "$artifact" "$build_number"
) >>"$BUILD_LOG" 2>&1; then
  fail_build "macOS Debug" "build or artifact verification failed"
fi
if ! write_single_line "$MACOS_DIR/BUILD_NUMBER" "$build_number" >>"$BUILD_LOG" 2>&1; then
  fail_build "macOS Debug" "artifact was built but apps/macos/BUILD_NUMBER could not be updated"
fi

printf 'OK macOS Debug %s (build %s; next build will increment)\nartifact: %s\nlog: %s\n' \
  "$version" "$build_number" "$artifact" "$BUILD_LOG"
