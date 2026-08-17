#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
component="${1:-}"
version="${2:-}"
artifact="${3:-}"
build_number="${4:-}"

usage() {
  echo "usage: $0 <macos> <version> <artifact-path> <build-number>" >&2
  exit 2
}

[[ "$component" == "macos" && -n "$version" && -n "$artifact" && -n "$build_number" ]] || usage
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "invalid artifact version: $version" >&2; exit 1; }
[[ "$build_number" =~ ^[1-9][0-9]*$ ]] || { echo "invalid artifact build number: $build_number" >&2; exit 1; }

case "$artifact" in
  /*) ;;
  *) artifact="$ROOT/$artifact" ;;
esac
artifact="$(cd "$(dirname "$artifact")" && pwd)/$(basename "$artifact")"
expected_parent="$ROOT/artifacts/$component/$version"
[[ "$(dirname "$artifact")" == "$expected_parent" ]] || { echo "artifact must be directly inside artifacts/$component/$version/" >&2; exit 1; }
[[ -d "$artifact" && -f "$artifact/Contents/Info.plist" ]] || { echo "invalid macOS app bundle: $artifact" >&2; exit 1; }

plist="$artifact/Contents/Info.plist"
[[ "$(plutil -extract CFBundleShortVersionString raw -o - "$plist")" == "$version" ]] || { echo "bundle version does not match $version" >&2; exit 1; }
[[ "$(plutil -extract CFBundleVersion raw -o - "$plist")" == "$build_number" ]] || { echo "bundle build number does not match $build_number" >&2; exit 1; }
codesign --verify --deep --strict --verbose=2 "$artifact"

printf 'verified %s %s (build %s): %s\n' "$component" "$version" "$build_number" "$artifact"
