#!/bin/bash

# Configuration Symlink Script
# Handles linking repository files to their system locations

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

backup_and_link() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    # Ensure target directory exists
    mkdir -p "$(dirname "$target")"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "${YELLOW}⚠️  Backing up existing $name to ${target}.backup${NC}"
        mv "$target" "${target}.backup"
    fi
    
    if [ -L "$target" ]; then
        local current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            echo -e "${GREEN}✅ $name already correctly symlinked${NC}"
            return
        else
            echo -e "${YELLOW}⚠️  Updating symlink for $name${NC}"
            rm "$target"
        fi
    fi
    
    ln -s "$source" "$target"
    echo -e "${GREEN}✅ Linked $name: $target → $source${NC}"
}

echo "🔗 Setting up configuration symlinks..."

# Tmux
backup_and_link "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf" "tmux.conf"
backup_and_link "$REPO_DIR/tmux.conf" "$HOME/.config/tmux/tmux.conf" "tmux.conf (config dir)"

# Starship
backup_and_link "$REPO_DIR/starship.toml" "$HOME/.config/starship.toml" "starship.toml"

# Ghostty
backup_and_link "$REPO_DIR/ghostty.conf" "$HOME/.config/ghostty/config" "ghostty config"

# Machine-specific Tmux settings
backup_and_link "$REPO_DIR/tmux.conf.local" "$HOME/.tmux.conf.local" "tmux.conf.local"

# Yazi
backup_and_link "$REPO_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml" "Yazi config"
backup_and_link "$REPO_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml" "Yazi keymap"
backup_and_link "$REPO_DIR/yazi/package.toml" "$HOME/.config/yazi/package.toml" "Yazi package manifest"

echo -e "${GREEN}✨ Symlink setup complete!${NC}"
