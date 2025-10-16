#!/usr/bin/env bash
# ==============================================================================
# Bootstrap script for Debian-based servers
# ==============================================================================
set -euo pipefail

# -----------------------------
# Determine script directory
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# -----------------------------
# Check for root or sudo
# -----------------------------
if [[ $EUID -ne 0 ]]; then
  echo "Warning: Some steps may require sudo privileges."
fi

# -----------------------------
# Install dependencies
# -----------------------------
echo "Installing required packages..."
sudo apt update
sudo apt install -y stow git zsh curl wget eza fzf zoxide tmux

# -----------------------------
# Setup Zsh as default shell
# -----------------------------
if ! command -v zsh &>/dev/null; then
  echo "Zsh not found, installing..."
  sudo apt install -y zsh
fi

if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)" "$USER"
fi

# -----------------------------
# GNU Stow deployment
# -----------------------------
echo "Deploying dotfiles with GNU Stow..."
# Se asume que estamos dentro de la carpeta dotfiles-server
stow .

# -----------------------------
# Finish
# -----------------------------
echo "Bootstrap complete!"
echo "Open a new terminal or run 'exec zsh' to start using your new environment."
