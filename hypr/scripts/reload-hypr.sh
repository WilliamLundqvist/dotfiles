#!/usr/bin/env bash
# Reload Hyprland config then re-apply monitor layout (fixes cursor traversal).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

hyprctl reload
sleep 0.3
"$SCRIPT_DIR/apply-monitors.sh" "${@}"
