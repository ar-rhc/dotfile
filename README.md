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

## Branch Strategy

Each machine has its own branch. Shared config lives on `main`; machine-specific files never get committed there.

```
main          → shared files (sketchybar, aerospace, hammerspoon, etc.)
macmini       → main + mac mini specific files (ssh/config, etc.)
macbook       → main + macbook specific files (ssh/config, etc.)
```

**To pull shared updates into a machine branch:**
```bash
git merge main
```

**Machine-specific files are protected from merges** via `.gitattributes` on each branch:
```
ssh/config merge=ours
```

This ensures `git merge main` never overwrites machine-specific files even if a conflict arises.

**Rule:** if a file differs per machine, never commit it to `main`.

## License

MIT





