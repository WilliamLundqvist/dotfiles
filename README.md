# 🌌 HyDE Dotfiles (CachyOS + Hyprland)

Personal dotfiles for a clean, modular, and aesthetically pleasing Hyprland environment powered by **HyDE** on **CachyOS**.

## ✨ Features
- **Modular Configs:** Separation of keybindings, window rules, and animations.
- **HyDE Integration:** Full support for themes, wallbash (dynamic coloring), and global wallpapers.
- **Artemis Theme:** A custom dark-aesthetic theme included in `hyde/themes/Artemis`.
- **Wallbash:** Dynamic UI coloring based on your current wallpaper.
- **Smart Package Search:** Integrated `pkgsearch.sh` script (Super + Alt + I).

## 🛠️ Structure
- `hyde/`: HyDE configurations, themes, and wallbash templates.
- `hypr/`: Hyprland settings (Animations, Idle, Lock, Keybindings).
- `kitty/`: Terminal configuration with custom fonts and opacity.
- `waybar/`: Highly customized status bar with modular includes.

## 🚀 Installation
You can use the provided installation script to set up these dotfiles on a fresh CachyOS install.

```bash
git clone https://github.com/your-username/dotfiles.git ~/Projekt/dotfiles
cd ~/Projekt/dotfiles
chmod +x install.sh
./install.sh
```

The script will:
1. Install necessary dependencies via `yay`.
2. Backup existing configurations in `~/.config`.
3. Create symlinks from the repository to `~/.config`.
4. Initialize HyDE settings.

## ⌨️ Key Highlights
- `Super + Space`: Rofi application launcher.
- `Super + Alt + I`: Search and install packages (AUR/Repo).
- `Super + Alt + Left/Right`: Change wallpapers.
- `Super + Shift + T`: Select a theme.

## 🤖 Gemini Agent Integration
This repository contains a `GEMINI.md` file that allows the Gemini CLI agent to manage your system configuration directly. You can ask the agent to "sync my dotfiles" or "apply the Artemis theme" once the repository is loaded.

---
*Maintained with ❤️ on CachyOS.*
