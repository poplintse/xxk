#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> contracts: placeholder check"
grep -q '^openapi: 3[.]1[.]0$' "$REPO_ROOT/contracts/openapi.yaml"
grep -q '^paths: {}$' "$REPO_ROOT/contracts/openapi.yaml"

echo "==> macOS: swift test"
swift test --package-path "$REPO_ROOT/apps/macos"

echo "==> Android, iOS, Windows, backend: not configured; skipped"
echo "All configured tests passed."
