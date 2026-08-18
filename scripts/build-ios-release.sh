#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/build-common.sh"
create_build_log ios release
planned_target "iOS Release" "iOS" "${VERSION:-${1:-}}" ios
