# dotfiles-server

Minimal dotfiles setup for Debian-based servers.  
Includes Zsh, Powerlevel10k, tmux, and essential plugins with a bootstrap script for easy setup.

---

## Features

- **Zsh** configured with:
  - Powerlevel10k prompt
  - Zinit plugin manager
  - Plugins: syntax highlighting, autosuggestions, completions, fzf-tab
- **Tmux** minimal configuration
- GNU **Stow** to manage dotfiles cleanly
- `bootstrap.sh` for automatic setup on any Debian-based server

---

## Quick Start

### 1. Clone the repository

```bash
cd ~
git clone https://github.com/Kevin-Cuevas/dotfiles-server.git
cd dotfiles-server
```

### 2. Run the bootstrap script
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

This will:

- Install dependencies (stow, zsh, git, eza, fzf, etc.)

- Change your default shell to Zsh (if needed)

- Deploy your dotfiles using stow .

### 3. Reload your shell

After the script finishes, open a new terminal or run:
```bash
exec zsh
```
