#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required_tools=(git xcodebuild swift xcrun)
optional_tools=(gh java javac gradle adb sdkmanager node npm pnpm dotnet msbuild docker)
missing_required=0

echo "Git repository"
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf '  [ok]      repository initialized\n'
else
  printf '  [missing] Git repository\n'
  missing_required=1
fi
if [[ "$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || true)" == "main" ]]; then
  printf '  [ok]      main branch\n'
else
  printf '  [missing] main branch\n'
  missing_required=1
fi
origin_url="$(git -C "$REPO_ROOT" config --get remote.origin.url 2>/dev/null || true)"
if [[ "$origin_url" == git@github.com:* ]]; then
  printf '  [ok]      GitHub SSH origin: %s\n' "$origin_url"
else
  printf '  [missing] GitHub SSH origin\n'
  missing_required=1
fi

echo "Required current toolchain"
for tool in "${required_tools[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  [ok]      %-12s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '  [missing] %-12s\n' "$tool"
    missing_required=1
  fi
done

echo "Planned-platform toolchain (informational)"
for tool in "${optional_tools[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  [available] %-12s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '  [not set]   %-12s\n' "$tool"
  fi
done

echo "Project structure"
required_paths=(
  apps/android
  apps/ios
  apps/macos/Package.swift
  apps/windows
  services/backend
  packages/contracts
  packages/apple-shared
  product
  contracts/openapi.yaml
  docs/VISION.md
  docs/CURRENT.md
  docs/DECISIONS.md
  scripts/test.sh
  .github/workflows/ci.yml
  .gitignore
)
for path in "${required_paths[@]}"; do
  if [[ -e "$REPO_ROOT/$path" ]]; then
    printf '  [ok]      %s\n' "$path"
  else
    printf '  [missing] %s\n' "$path"
    missing_required=1
  fi
done

if [[ "$missing_required" -ne 0 ]]; then
  echo "Environment check failed."
  exit 1
fi

echo "Environment check passed for the currently implemented macOS project."
