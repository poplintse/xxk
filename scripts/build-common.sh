#!/usr/bin/env bash

set -euo pipefail

readonly BUILD_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly COMPONENT_BUILD_NUMBERS_FILE="$BUILD_ROOT/release/BUILD_NUMBERS"

is_semver() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

create_build_log() {
  local component="$1"
  local configuration="$2"
  local log_dir="$BUILD_ROOT/artifacts/logs"

  mkdir -p "$log_dir"
  BUILD_LOG="$log_dir/${component}-${configuration}-$(date +%Y%m%d-%H%M%S)-$$.log"
  : >"$BUILD_LOG"
}

fail_build() {
  local label="$1"
  local message="$2"
  local status="${3:-1}"

  printf '%s\n' "$message" >>"$BUILD_LOG"
  printf 'FAILED %s: %s\nlog: %s\n' "$label" "$message" "$BUILD_LOG" >&2
  exit "$status"
}

read_single_line() {
  local file="$1"
  tr -d '[:space:]' <"$file"
}

next_macos_build_number() {
  local source_build="$1"
  local highest="$source_build"
  local plist
  local artifact_build

  while IFS= read -r plist; do
    artifact_build="$(plutil -extract CFBundleVersion raw -o - "$plist" 2>/dev/null || true)"
    if [[ "$artifact_build" =~ ^[1-9][0-9]*$ ]] && (( artifact_build > highest )); then
      highest="$artifact_build"
    fi
  done < <(find "$BUILD_ROOT/artifacts/macos" -type f -path '*/Contents/Info.plist' -print 2>/dev/null)

  printf '%s\n' "$((highest + 1))"
}

acquire_macos_build_lock() {
  MACOS_BUILD_LOCK="$BUILD_ROOT/artifacts/.locks/macos-build-number"
  mkdir -p "$(dirname "$MACOS_BUILD_LOCK")"
  mkdir "$MACOS_BUILD_LOCK" 2>/dev/null
}

release_macos_build_lock() {
  [[ -n "${MACOS_BUILD_LOCK:-}" ]] && rmdir "$MACOS_BUILD_LOCK" 2>/dev/null || true
}

write_single_line() {
  local file="$1"
  local value="$2"
  local temporary="$file.tmp.$$"

  printf '%s\n' "$value" >"$temporary"
  mv "$temporary" "$file"
}

read_component_build_number() {
  local component="$1"
  local value

  [[ -f "$COMPONENT_BUILD_NUMBERS_FILE" ]] || return 1
  value="$(sed -n "s/^${component}=//p" "$COMPONENT_BUILD_NUMBERS_FILE")"
  [[ "$value" =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "$value"
}

next_component_build_number() {
  local component="$1"
  local current

  current="$(read_component_build_number "$component")"
  printf '%s\n' "$((current + 1))"
}

acquire_component_build_lock() {
  local component="$1"

  COMPONENT_BUILD_LOCK="$BUILD_ROOT/artifacts/.locks/${component}-build-number"
  mkdir -p "$(dirname "$COMPONENT_BUILD_LOCK")"
  mkdir "$COMPONENT_BUILD_LOCK" 2>/dev/null
}

release_component_build_lock() {
  [[ -n "${COMPONENT_BUILD_LOCK:-}" ]] && rmdir "$COMPONENT_BUILD_LOCK" 2>/dev/null || true
}

record_component_build_number() {
  local component="$1"
  local build_number="$2"
  local temporary="$COMPONENT_BUILD_NUMBERS_FILE.tmp.$$"

  [[ "$build_number" =~ ^[1-9][0-9]*$ ]] || return 1
  sed "s/^${component}=.*/${component}=${build_number}/" \
    "$COMPONENT_BUILD_NUMBERS_FILE" >"$temporary"
  if ! grep -qx "${component}=${build_number}" "$temporary"; then
    rm -f "$temporary"
    return 1
  fi
  mv "$temporary" "$COMPONENT_BUILD_NUMBERS_FILE"
}

planned_target() {
  local label="$1"
  local platform="$2"
  local version="$3"
  local component="$4"
  local next_build

  if [[ -n "$version" ]] && ! is_semver "$version"; then
    fail_build "$label" "invalid VERSION: $version" 2
  fi

  if ! acquire_component_build_lock "$component"; then
    fail_build "$label" "another $platform build is already assigning a build number"
  fi
  trap release_component_build_lock EXIT HUP INT TERM
  next_build="$(next_component_build_number "$component")"
  fail_build "$label" "$platform has no buildable project in this repository; build $next_build was not allocated" 2
}
