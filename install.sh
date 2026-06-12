#!/bin/bash
# Complete dotfiles installation script for new macOS machine
# Installs AeroSpace, Hammerspoon, SketchyBar, and all dependencies

set -e  # Exit on error

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting dotfiles installation..."
echo "Repository: $REPO_DIR"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script is for macOS only${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Homebrew if not present
install_homebrew() {
    if ! command_exists brew; then
        echo -e "${YELLOW}📦 Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo -e "${GREEN}✅ Homebrew already installed${NC}"
    fi
}

# Function to install a package if not already installed
install_package() {
    local package=$1
    local name=$2
    
    if brew list "$package" &>/dev/null; then
        echo -e "${GREEN}✅ $name already installed${NC}"
    else
        echo -e "${YELLOW}📦 Installing $name...${NC}"
        brew install "$package"
    fi
}

# Function to install a cask if not already installed
install_cask() {
    local cask=$1
    local name=$2
    
    if brew list --cask "$cask" &>/dev/null; then
        echo -e "${GREEN}✅ $name already installed${NC}"
    else
        echo -e "${YELLOW}📦 Installing $name...${NC}"
        brew install --cask "$cask"
    fi
}

# Step 1: Install Homebrew
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 1: Installing Homebrew${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
install_homebrew
echo ""

# Step 2: Install dependencies
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 2: Installing dependencies${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
install_package "jq" "jq"
install_package "curl" "curl"
install_package "python3" "Python 3"
echo ""

# Step 3: Install Fonts
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 3: Installing Fonts${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
install_cask "font-sketchybar-app-font" "SketchyBar App Font"
install_cask "sf-symbols" "SF Symbols"
echo -e "${GREEN}✅ Fonts installed${NC}"
echo -e "${YELLOW}ℹ️  Note: SF Pro is a system font and should already be available${NC}"
echo ""

# Step 4: Install AeroSpace
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 4: Installing AeroSpace${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if command_exists aerospace; then
    echo -e "${GREEN}✅ AeroSpace already installed${NC}"
else
    echo -e "${YELLOW}📦 Installing AeroSpace...${NC}"
    # Try tap method first
    if brew tap nikitabobko/tap 2>/dev/null && brew install --cask nikitabobko/tap/aerospace 2>/dev/null; then
        echo -e "${GREEN}✅ AeroSpace installed via Homebrew${NC}"
    else
        echo -e "${YELLOW}⚠️  Homebrew installation failed, downloading manually...${NC}"
        AEROSPACE_URL="https://github.com/nikitabobko/AeroSpace/releases/latest/download/AeroSpace.zip"
        TEMP_DIR=$(mktemp -d)
        curl -L "$AEROSPACE_URL" -o "$TEMP_DIR/AeroSpace.zip"
        unzip -q "$TEMP_DIR/AeroSpace.zip" -d "$TEMP_DIR"
        sudo mv "$TEMP_DIR/AeroSpace.app" /Applications/ 2>/dev/null || mv "$TEMP_DIR/AeroSpace.app" /Applications/
        xattr -cr /Applications/AeroSpace.app
        rm -rf "$TEMP_DIR"
        echo -e "${GREEN}✅ AeroSpace installed manually${NC}"
    fi
    echo -e "${YELLOW}⚠️  Note: You may need to grant Accessibility permissions to AeroSpace${NC}"
    echo -e "${YELLOW}   Go to: System Settings → Privacy & Security → Accessibility${NC}"
fi
echo ""

# Step 5: Install SketchyBar
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 5: Installing SketchyBar${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if command_exists sketchybar; then
    echo -e "${GREEN}✅ SketchyBar already installed${NC}"
else
    echo -e "${YELLOW}📦 Installing SketchyBar...${NC}"
    # Add SketchyBar tap first
    brew tap FelixKratz/formulae
    brew install sketchybar
    echo -e "${GREEN}✅ SketchyBar installed${NC}"
    echo -e "${YELLOW}⚠️  Note: You may need to grant Accessibility permissions to SketchyBar${NC}"
    echo -e "${YELLOW}   Go to: System Settings → Privacy & Security → Accessibility${NC}"
fi
echo ""

# Step 6: Install Hammerspoon
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 6: Installing Hammerspoon${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if command_exists hammerspoon; then
    echo -e "${GREEN}✅ Hammerspoon already installed${NC}"
else
    echo -e "${YELLOW}📦 Installing Hammerspoon...${NC}"
    brew install --cask hammerspoon
    echo -e "${YELLOW}⚠️  Note: You may need to grant Accessibility permissions to Hammerspoon${NC}"
    echo -e "${YELLOW}   Go to: System Settings → Privacy & Security → Accessibility${NC}"
fi
echo ""

# Step 7: Install JankyBorders
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 7: Installing JankyBorders${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if command_exists borders || brew list borders &>/dev/null; then
    echo -e "${GREEN}✅ JankyBorders already installed${NC}"
else
    echo -e "${YELLOW}📦 Installing JankyBorders...${NC}"
    # Add FelixKratz tap (if not already added for SketchyBar)
    brew tap FelixKratz/formulae 2>/dev/null || true
    brew install borders
    echo -e "${GREEN}✅ JankyBorders installed${NC}"
fi
echo ""

# Step 8: Create config directories
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 8: Creating config directories${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
mkdir -p ~/.config
echo -e "${GREEN}✅ Config directory created${NC}"
echo ""

# Step 9: Backup and create symlinks
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 9: Creating symlinks${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

backup_and_link() {
    local target="$1"
    local source="$2"
    local name="$3"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "${YELLOW}⚠️  Backing up existing $name to ${target}.backup${NC}"
        mv "$target" "${target}.backup"
    fi
    
    if [ -L "$target" ]; then
        # Check if symlink points to the right place
        local current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            echo -e "${GREEN}✅ $name already correctly symlinked${NC}"
            return
        else
            echo -e "${YELLOW}⚠️  Removing incorrect symlink for $name${NC}"
            rm "$target"
        fi
    fi
    
        ln -sfn "$source" "$target"
    echo -e "${GREEN}✅ Linked $name: $target → $source${NC}"
}

# Create symlinks
mkdir -p ~/.ssh
backup_and_link ~/.ssh/config "$REPO_DIR/ssh/config" "ssh/config"
backup_and_link ~/.aerospace.toml "$REPO_DIR/aerospace/aerospace.toml" "aerospace.toml"
mkdir -p ~/.config/aerospace
backup_and_link ~/.config/aerospace/scripts "$REPO_DIR/aerospace/scripts" "aerospace/scripts"
backup_and_link ~/.config/sketchybar "$REPO_DIR/sketchybar" "sketchybar"
backup_and_link ~/.hammerspoon "$REPO_DIR/hammerspoon" "hammerspoon"
echo ""

# Step 10: Build SketchyBar helper
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 10: Building SketchyBar helper${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -d "$REPO_DIR/sketchybar/helper" ]; then
    echo -e "${YELLOW}🔨 Building helper binary...${NC}"
    (cd "$REPO_DIR/sketchybar/helper" && make)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Helper binary built successfully${NC}"
    else
        echo -e "${RED}❌ Failed to build helper binary${NC}"
        echo -e "${YELLOW}   Make sure Xcode Command Line Tools are installed:${NC}"
        echo -e "${YELLOW}   xcode-select --install${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Helper directory not found, skipping${NC}"
fi
echo ""

# Step 11: Start services
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 11: Starting services${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Start SketchyBar
if command_exists sketchybar; then
    # Check if SketchyBar is already running
    if pgrep -x "sketchybar" > /dev/null; then
        echo -e "${YELLOW}🔄 SketchyBar is already running, reloading...${NC}"
        sketchybar --reload
        sleep 2
        # Restart to ensure fonts are loaded properly
        sketchybar --restart 2>/dev/null || true
        sleep 2
        echo -e "${GREEN}✅ SketchyBar reloaded (fonts loaded)${NC}"
    else
        echo -e "${YELLOW}🚀 Starting SketchyBar...${NC}"
        brew services start sketchybar 2>/dev/null || sketchybar --reload
        sleep 3
        # Restart to ensure fonts are loaded properly
        sketchybar --restart 2>/dev/null || true
        sleep 2
        echo -e "${GREEN}✅ SketchyBar started and restarted (fonts loaded)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  SketchyBar not found, skipping${NC}"
fi

# Start JankyBorders
if command_exists borders || brew list borders &>/dev/null; then
    echo -e "${YELLOW}🚀 Starting JankyBorders...${NC}"
    brew services start borders 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ JankyBorders started${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not start borders service (may need to be started manually)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  JankyBorders not found, skipping${NC}"
fi

echo ""

# Step 12: Final instructions
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo ""
echo -e "1. ${YELLOW}Grant Accessibility Permissions:${NC}"
echo -e "   • Open System Settings → Privacy & Security → Accessibility"
echo -e "   • Enable: AeroSpace, SketchyBar, Hammerspoon"
echo ""
echo -e "2. ${YELLOW}Start Hammerspoon:${NC}"
echo -e "   • Open the app from Applications"
echo ""
echo -e "3. ${YELLOW}If icons are not showing correctly:${NC}"
echo -e "   • Restart SketchyBar: sketchybar --restart"
echo -e "   • Verify fonts are installed:"
echo -e "     - SF Pro (system font, should be available)"
echo -e "     - SketchyBar App Font (installed)"
echo -e "     - SF Symbols (installed)"
echo ""
echo -e "4. ${YELLOW}Optional dependencies:${NC}"
echo -e "   • Install 'macism' for input source switching:"
echo -e "     brew install macism"
echo ""
echo -e "${GREEN}🎉 Your dotfiles are now set up!${NC}"
echo -e "${GREEN}SketchyBar and JankyBorders have been started automatically.${NC}"
