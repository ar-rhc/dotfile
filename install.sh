#!/bin/bash
# Dotfiles installation script

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $REPO_DIR"

# Create directories if they don't exist
mkdir -p ~/.config

# Backup and create symlinks
backup_and_link() {
    local target="$1"
    local source="$2"
    local name="$3"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "⚠️  Backing up existing $name to ${target}.backup"
        mv "$target" "${target}.backup"
    fi
    
    if [ -L "$target" ]; then
        echo "ℹ️  $name already symlinked, skipping"
    else
        ln -sfn "$source" "$target"
        echo "✅ Linked $name: $target → $source"
    fi
}

# Create symlinks
backup_and_link ~/.aerospace.toml "$REPO_DIR/aerospace.toml" "aerospace.toml"
backup_and_link ~/.config/sketchybar "$REPO_DIR/sketchybar" "sketchybar"
backup_and_link ~/.config/skhd "$REPO_DIR/skhd" "skhd"
backup_and_link ~/.config/yabai "$REPO_DIR/yabai" "yabai"
backup_and_link ~/.config/borders "$REPO_DIR/borders" "borders"
backup_and_link ~/.hammerspoon "$REPO_DIR/hammerspoon" "hammerspoon"

echo ""
echo "✅ Dotfiles installation complete!"
echo "Your config files are now symlinked to the repository."
