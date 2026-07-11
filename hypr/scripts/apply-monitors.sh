#!/usr/bin/env bash
# Apply monitor layout by stable description IDs (survives port renames).
#
# Layout:
#   [Samsung 1440p][MSI 1080p]     ← top row, Samsung always left
#   [Laptop (optional)]              ← below Samsung when lid is open

set -euo pipefail

readonly LAPTOP_DESC='Samsung Display Corp. 0x4178'
readonly SAMSUNG_DESC='Samsung Electric Company LC27G7xT HNBW800080'
readonly MSI_DESC='Microstep Optix G24C 0x00000001'

readonly LAPTOP_MODE='3200x2000@120'
readonly SAMSUNG_MODE='2560x1440@144'
readonly MSI_MODE='1920x1080@120'

readonly SAMSUNG_SCALE='1.25'
readonly MSI_SCALE='1'
readonly LAPTOP_SCALE='1.6'

log() { printf '[apply-monitors] %s\n' "$*"; }

scaled_width() {
    local res=$1 scale=$2
    local w=${res%%x*}
    python3 -c "print(int($w / $scale))"
}

scaled_height() {
    local res=$1 scale=$2
    local h=${res#*x}
    h=${h%%@*}
    python3 -c "print(int($h / $scale))"
}

is_drm_connected() {
    local port=$1
    local status_file
    for status_file in /sys/class/drm/card*-{eDP,DP,HDMI}*/status; do
        [[ -f $status_file ]] || continue
        [[ $(basename "$(dirname "$status_file")") == *"$port"* ]] || continue
        [[ $(cat "$status_file") == connected ]] && return 0
    done
    return 1
}

is_connected() {
    local desc=$1
    hyprctl monitors -j | jq -e --arg d "$desc" '.[] | select(.description == $d)' >/dev/null 2>&1 && return 0
    [[ $desc == "$LAPTOP_DESC" ]] && is_drm_connected 'eDP' && return 0
    return 1
}

lid_is_closed() {
    [[ "${1:-}" == "--lid-closed" ]] && return 0
    local state
    for state in /proc/acpi/button/lid/*/state; do
        [[ -f $state ]] && grep -qE '^state:[[:space:]]*closed' "$state" && return 0
    done
    return 1
}

apply_monitor() {
    local desc=$1 mode=$2 position=$3 scale=$4
    hyprctl keyword monitor "desc:${desc}, ${mode}, ${position}, ${scale}" >/dev/null
    log "desc:${desc} → ${mode} @ ${position} scale ${scale}"
}

disable_monitor() {
    local desc=$1
    hyprctl keyword monitor "desc:${desc}, disable" >/dev/null
    log "desc:${desc} → disabled"
}

main() {
    command -v hyprctl >/dev/null || { log 'hyprctl not found'; exit 0; }
    command -v jq >/dev/null || { log 'jq not found'; exit 1; }

    local use_laptop=false
    if is_connected "$LAPTOP_DESC" && ! lid_is_closed "${1:-}"; then
        use_laptop=true
    fi

    local samsung_w samsung_h
    samsung_w=$(scaled_width "$SAMSUNG_MODE" "$SAMSUNG_SCALE")
    samsung_h=$(scaled_height "$SAMSUNG_MODE" "$SAMSUNG_SCALE")

    # Disable laptop first so it cannot steal auto-layout anchor
    if ! $use_laptop && is_connected "$LAPTOP_DESC"; then
        disable_monitor "$LAPTOP_DESC"
        sleep 0.15
    fi

    # Anchor Samsung left, then MSI flush to its right (no gap)
    apply_monitor "$SAMSUNG_DESC" "$SAMSUNG_MODE" '0x0' "$SAMSUNG_SCALE"
    sleep 0.15
    apply_monitor "$MSI_DESC" "$MSI_MODE" "${samsung_w}x0" "$MSI_SCALE"
    sleep 0.15

    if $use_laptop; then
        apply_monitor "$LAPTOP_DESC" "$LAPTOP_MODE" "0x${samsung_h}" "$LAPTOP_SCALE"
        log "profile: docked (3 monitors)"
    else
        log "profile: externals only (2 monitors)"
    fi
}

main "$@"
