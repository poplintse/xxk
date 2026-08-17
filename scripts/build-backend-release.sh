#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/build-common.sh"
create_build_log backend release
planned_target "Backend Release" "Backend" "${VERSION:-${1:-}}"
