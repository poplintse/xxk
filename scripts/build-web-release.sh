#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/build-common.sh"
create_build_log web release
planned_target "Web Release" "Web" "${VERSION:-${1:-}}" web
