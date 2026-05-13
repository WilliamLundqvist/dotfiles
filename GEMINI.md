# Gemini Dotfiles Management Rules

This repository is the **Source of Truth** for the system's Hyprland and HyDE configuration.

## 🤖 Gemini Workflow
When managing this repository, always follow these procedures:

### 1. Synchronization (The "Sync" Command)
If the user asks to "sync my dotfiles" or "apply my config":
1. Verify that `~/.config/hypr`, `~/.config/waybar`, `~/.config/kitty`, and `~/.config/hyde` are symlinks pointing to this repository.
2. If any are missing or are regular directories, move the content to this repo and create a symlink.
3. Run `hyde theme set Artemis` (or the current preferred theme) to ensure all wallbash templates are generated.
4. Reload Hyprland with `hyprctl reload`.

### 2. Adding New Configurations
When the user installs a new tool or creates a new config in `~/.config`:
1. Check if it should be version-controlled.
2. Move the directory/file to `~/Projekt/dotfiles/`.
3. Create a symlink from `~/.config/` back to the repository.
4. Update the `README.md` if it's a major component.

### 3. Theme & Wallbash
- Always use HyDE commands for theme switching: `hyde theme set <theme_name>`.
- To trigger a color update after a wallpaper change: `hyde wallpaper <path_to_wall>`.
- Use `hyde-shell` for system-level scripts as per HyDE standards.

### 4. Safety
- Never commit `.env` files or sensitive credentials that might accidentally end up in config folders.
- Always perform a `git status` before suggesting a commit.

## 📦 Key Dependencies
- `hyprland`, `waybar`, `kitty`, `rofi-wayland`, `swaync`, `hyprlock`, `hypridle`.
- `hyde-cli` (installed via HyDE).
- `brightnessctl`, `playerctl`, `jq`, `cliphist`.
