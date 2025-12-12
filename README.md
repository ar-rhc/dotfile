# Dotfiles

My macOS dotfiles configuration for window management, status bar, and system customization.

## Contents

- **aerospace.toml** - AeroSpace tiling window manager configuration
- **sketchybar/** - SketchyBar status bar configuration with custom widgets
- **skhd/** - Simple Hotkey Daemon keybindings
- **yabai/** - Yabai window manager config (legacy)
- **hammerspoon/** - Hammerspoon automation scripts
- **borders/** - JankyBorders configuration

## Setup

These dotfiles use symlinks to the actual config locations:
- `aerospace.toml symlink` → `~/.aerospace.toml`
- `sketchybar symlink` → `~/.config/sketchybar`
- `skhd symlink` → `~/.config/skhd`
- `yabai symlink` → `~/.config/yabai`
- `hammerspoon symlink` → `~/.hammerspoon`
- `borders symlink` → `~/.config/borders`

## Requirements

- macOS
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) - Tiling window manager
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) - Status bar
- [SKHD](https://github.com/koekeishiya/skhd) - Hotkey daemon
- [JankyBorders](https://github.com/unixpickle/jankyborders) - Window borders

## Features

### AeroSpace
- Custom workspace assignments to monitors
- Service mode and app mode for quick actions
- Window detection rules for floating windows
- Custom keybindings for window management

### SketchyBar
- Custom workspace indicators
- CPU monitoring with helper binary
- Weather, calendar, and notifications widgets
- Service/app mode indicators
- Custom notification badges

## Installation

1. Clone this repository
2. Create symlinks to the actual config locations
3. Install required dependencies
4. Rebuild helper binaries: `cd sketchybar\ symlink/helper && make`

## License

MIT

