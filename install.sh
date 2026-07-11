#!/usr/bin/env bash

# HyDE Dotfiles Installation Script
# Tailored for CachyOS + Hyprland

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "${BLUE}🚀 Starting Dotfiles Installation...${NC}\n"

# 1. Check if running on CachyOS (optional but helpful)
if [ -f /etc/os-release ]; then
    if ! grep -qi "cachyos" /etc/os-release; then
        printf "${YELLOW}⚠️ Warning: This script is optimized for CachyOS. Proceeding anyway...${NC}\n"
    fi
fi

# 2. Ensure yay is installed
if ! command -v yay &> /dev/null; then
    printf "${BLUE}📦 Installing yay...${NC}\n"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
fi

# 3. Install Core Dependencies
printf "${BLUE}📦 Installing dependencies...${NC}\n"
DEPENDENCIES=(
    hyprland
    waybar
    kitty
    rofi-wayland
    swaync
    hyprlock
    hypridle
    brightnessctl
    playerctl
    jq
    cliphist
    polkit-kde-agent
    xdg-desktop-portal-hyprland
    qt5-wayland
    qt6-wayland
    nwg-look
    socat
)

# Optional: Add HyDE specific tools if they are in repos or AUR
# hyde-cli might be one if you use it

yay -S --needed --noconfirm "${DEPENDENCIES[@]}"

# 4. Create Symlinks
printf "${BLUE}🔗 Creating Symlinks...${NC}\n"
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/Projekt/dotfiles"

mkdir -p "$CONFIG_DIR"

# Function to safely symlink
safe_link() {
    local target=$1
    local source=$2
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        printf "${YELLOW}📂 Backing up existing $target to ${target}.bak${NC}\n"
        mv "$target" "${target}.bak"
    fi
    ln -sfn "$source" "$target"
    printf "${GREEN}✅ Linked $target${NC}\n"
}

safe_link "$CONFIG_DIR/hypr" "$DOTFILES_DIR/hypr"
safe_link "$CONFIG_DIR/waybar" "$DOTFILES_DIR/waybar"
safe_link "$CONFIG_DIR/kitty" "$DOTFILES_DIR/kitty"
safe_link "$CONFIG_DIR/hyde" "$DOTFILES_DIR/hyde"

mkdir -p "$CONFIG_DIR/swaync"
safe_link "$CONFIG_DIR/swaync/style.css" "$DOTFILES_DIR/swaync/style.css"
safe_link "$CONFIG_DIR/swaync/user-style.css" "$DOTFILES_DIR/swaync/user-style.css"
safe_link "$CONFIG_DIR/swaync/config.json" "$DOTFILES_DIR/swaync/config.json"

# 5. Initialize HyDE
if command -v hyde-shell &> /dev/null; then
    printf "${BLUE}🎨 Initializing HyDE themes...${NC}\n"
    # Example: hyde theme set Artemis
fi

printf "${GREEN}✨ Installation Complete! Please restart Hyprland.${NC}\n"
printf "Tip: Use Super+Alt+I to search for more packages.\n"
