# Dotfiles Setup Guide

This repository centralizes configuration files for a high-performance macOS terminal environment using Ghostty, Tmux, and various QOL tools.

## 1. Prerequisites (Homebrew)
Install Homebrew if not already present:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install core tools:
```bash
brew install ghostty tmux zoxide fzf fd jq starship zsh-syntax-highlighting zsh-autosuggestions bat lazygit
brew install --cask font-jetbrains-mono-nerd-font
```

## 2. Symlink Configurations
Run these commands to link the centralized config files to their expected locations:

### Ghostty
```bash
mkdir -p ~/.config/ghostty
ln -s ~/ARfiles/dotfile/ghostty.conf ~/.config/ghostty/config
```

### Tmux
```bash
ln -s ~/ARfiles/dotfile/tmux.conf ~/.tmux.conf
```

### Starship
```bash
ln -s ~/ARfiles/dotfile/starship.toml ~/.config/starship.toml
```

## 3. Zsh Configuration (`~/.zshrc`)
Add the following to your `~/.zshrc`:

### Completion Initialization (Required for many CLI tools)
```zsh
autoload -Uz compinit && compinit
```

### Zoxide (Smart cd)
```zsh
eval "$(zoxide init zsh)"
```

### Maintenance & Productivity Aliases
```zsh
alias brew-clean='brew update && brew upgrade; brew cleanup --force; rm -rf $(brew --cache)'
alias cat='bat'
alias lg='lazygit'
alias ide='~/ARfiles/dotfile/layout.sh'
```

### Prompt & Visuals (Starship)
Add these to the end of your `~/.zshrc`:
```zsh
eval "$(starship init zsh)"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

## 4. Ghostty + Tmux Integration
The `ghostty.conf` is pre-configured to:
- Automatically launch or attach to a Tmux session.
- Map macOS shortcuts (`Cmd+T`, `Cmd+W`, `Cmd+1-9`) to Tmux actions.
- Enable a "Quick Terminal" (Visor style) on `Option + Space`.

## 5. Tmux Features
The `tmux.conf` includes:
- Mouse support (scrolling and clicking).
- Truecolor support.
- Status bar window switching via scroll wheel.
- **Persistence:** New windows/panes open in the current directory.

## 6. Prompt Customization (Starship)
The `starship.toml` is configured for a professional, balanced look:
- **Identity:** Shows `user@hostname` in bold yellow and green.
- **Path:** Shows the current directory in bold cyan.
- **Symbol:** Uses a traditional `$` (green for success, red for error).
- **Cleanliness:** All unnecessary modules (Git, Node, Cloud, etc.) are disabled for maximum focus.

## 7. Development Layout (`ide`)
The `ide` alias runs a script that:
1. Creates a new Tmux session named after your current folder.
2. Window 1 (`code`): Split into a main area and a 30% side terminal.
3. Window 2 (`git`): Automatically launches `lazygit`.

## 8. How to use Zoxide (Smart `cd`)
Zoxide is a smarter way to navigate your filesystem. It remembers the directories you visit.

- **Initial Setup:** You must `cd` into a directory **at least once** before Zoxide can "remember" it.
  - Example: `cd ~/ARfiles/dotfile`
- **Jumping:** Once remembered, use `z` and a partial name to jump back there from anywhere.
  - Example: `z dotfile`
- **Interactive Jump:** Use `zi` to open an interactive fuzzy finder (powered by `fzf`) to pick from your most visited directories.
