#!/usr/bin/env bash
# Re-apply monitor layout on hotplug events.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPLY_SCRIPT="${SCRIPT_DIR}/apply-monitors.sh"
SIGNATURE="${HYPRLAND_INSTANCE_SIGNATURE:-}"

[[ -n $SIGNATURE ]] || exit 0
command -v socat >/dev/null || exit 0
[[ -S "${XDG_RUNTIME_DIR}/hypr/${SIGNATURE}/.socket2.sock" ]] || exit 0

socat -u "UNIX-CONNECT:${XDG_RUNTIME_DIR}/hypr/${SIGNATURE}/.socket2.sock" - |
    while read -r line; do
        case "$line" in
            monitoradded* | monitorremoved*)
                sleep 0.5
                "$APPLY_SCRIPT"
                ;;
        esac
    done
