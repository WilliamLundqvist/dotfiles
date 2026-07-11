#!/usr/bin/env bash
# Sync Artemis wallpapers to SDDM login screen and hyprlock (screensaver/lock).

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projekt/dotfiles}"
ARTEMIS_DIR="$DOTFILES/hyde/themes/Artemis"
ARTEMIS_WALLS="$ARTEMIS_DIR/wallpapers"
SDDM_BG="/usr/share/sddm/themes/Corners/backgrounds/bg.png"
SDDM_TMP="/var/tmp/hyde-sddm-wall.png"

log() { printf '[sync-wallpapers] %s\n' "$*"; }

get_wallpaper() {
    local wall=""
    for candidate in \
        "$HOME/.cache/hyde/wall.set" \
        "$ARTEMIS_DIR/wall.set" \
        "$ARTEMIS_WALLS/earth_from_orion.jpg"; do
        if [[ -L $candidate || -f $candidate ]]; then
            wall=$(readlink -f "$candidate" 2>/dev/null || realpath "$candidate")
            [[ -f $wall ]] && { echo "$wall"; return 0; }
        fi
    done
    find "$ARTEMIS_WALLS" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) | head -1
}

sync_hyprlock() {
    command -v hyde-shell >/dev/null || return 0

    local target=""
    if [[ -L $ARTEMIS_DIR/wall.set ]]; then
        target=$(readlink -f "$ARTEMIS_DIR/wall.set")
        ln -sfn "$target" "$ARTEMIS_DIR/wall.hyprlock.png"
        ln -sfn "$target" "$ARTEMIS_DIR/wall.awww.png"
    fi

    # Regenerate lock screen PNG from the global Artemis wallpaper
    hyde-shell hyprlock.sh --background 2>/dev/null || true
    log "hyprlock background synced"
}

sync_sddm() {
    local wall=$1
    [[ -f $wall ]] || { log "no wallpaper found for SDDM"; return 1; }
    [[ -d $(dirname "$SDDM_BG") ]] || { log "SDDM Corners theme not found"; return 1; }

    if command -v magick >/dev/null; then
        magick "$wall"[0] -resize 2560x1440^ -gravity center -extent 2560x1440 "$SDDM_TMP"
    elif command -v convert >/dev/null; then
        convert "$wall"[0] -resize 2560x1440^ -gravity center -extent 2560x1440 "$SDDM_TMP"
    else
        cp -f "$wall" "$SDDM_TMP"
    fi

    if sudo -n cp -f "$SDDM_TMP" "$SDDM_BG" 2>/dev/null; then
        log "SDDM login wallpaper updated (passwordless)"
    elif sudo cp -f "$SDDM_TMP" "$SDDM_BG"; then
        log "SDDM login wallpaper updated"
    else
        log "SDDM sync skipped (sudo required)"
        return 1
    fi
}

main() {
    local wall
    wall=$(get_wallpaper)
    [[ -n $wall && -f $wall ]] || { log "no Artemis wallpaper found"; exit 1; }

    log "using: $wall"
    sync_hyprlock
    sync_sddm "$wall"
}

main "$@"
