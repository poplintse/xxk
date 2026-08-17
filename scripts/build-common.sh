#!/usr/bin/env bash

set -euo pipefail

readonly BUILD_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

planned_target() {
  local label="$1"
  local platform="$2"
  local version="$3"

  if [[ -n "$version" ]] && ! is_semver "$version"; then
    fail_build "$label" "invalid VERSION: $version" 2
  fi

  fail_build "$label" "$platform has no buildable project in this repository" 2
}
