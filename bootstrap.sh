#!/usr/bin/env bash
# ==============================================================================
# Bootstrap script for Debian-based servers (Modular & Idempotent)
# ==============================================================================
set -euo pipefail

# -----------------------------
# Colors for output
# -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# -----------------------------
# Helper functions
# -----------------------------
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# -----------------------------
# Determine script directory
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# -----------------------------
# Check for sudo privileges
# -----------------------------
check_sudo() {
  if [[ $EUID -ne 0 ]]; then
    if ! sudo -n true 2>/dev/null; then
      log_warn "This script requires sudo privileges. You may be prompted for your password."
      sudo -v
    fi
  fi
}

# -----------------------------
# Install dependencies
# -----------------------------
install_packages() {
  log_info "Checking and installing required packages..."

  local packages=(stow git zsh curl wget eza fzf zoxide tmux)
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
      to_install+=("$pkg")
    fi
  done

  if [[ ${#to_install[@]} -gt 0 ]]; then
    log_info "Installing: ${to_install[*]}"
    sudo apt update
    sudo apt install -y "${to_install[@]}"
  else
    log_info "All packages already installed. Skipping."
  fi
}

# -----------------------------
# Setup Zsh as default shell (PERMANENT)
# -----------------------------
setup_zsh_shell() {
  log_info "Setting up Zsh as default shell..."

  local zsh_path
  zsh_path=$(which zsh)

  if [[ -z "$zsh_path" ]]; then
    log_error "Zsh not found! Install it first."
    return 1
  fi

  # Check current shell in /etc/passwd
  local current_shell
  current_shell=$(getent passwd "$USER" | cut -d: -f7)

  if [[ "$current_shell" == "$zsh_path" ]]; then
    log_info "Zsh is already the default shell for $USER. Skipping."
    return 0
  fi

  log_info "Current shell: $current_shell"
  log_info "Changing shell to: $zsh_path"

  # Method 1: Try usermod (most reliable, requires sudo)
  if sudo usermod -s "$zsh_path" "$USER" 2>/dev/null; then
    log_info "Shell changed successfully using usermod!"
  else
    log_warn "usermod failed, trying chsh..."
    # Method 2: Fallback to chsh
    if chsh -s "$zsh_path" "$USER" 2>/dev/null; then
      log_info "Shell changed successfully using chsh!"
    else
      log_error "Failed to change shell. You may need to manually edit /etc/passwd"
      return 1
    fi
  fi

  # Verify the change
  local new_shell
  new_shell=$(getent passwd "$USER" | cut -d: -f7)
  if [[ "$new_shell" == "$zsh_path" ]]; then
    log_info "✓ Verified: Shell is now set to $zsh_path in /etc/passwd"
  else
    log_error "Shell change verification failed!"
    return 1
  fi
}

# -----------------------------
# GNU Stow deployment (Solo ejecuta si no existe)
# -----------------------------
deploy_dotfiles() {
  log_info "Checking dotfiles deployment status..."

  # Check if stow has already been run by looking for symlinks
  if [[ -L "$HOME/.zshrc" ]] || [[ -L "$HOME/.tmux.conf" ]] || [[ -L "$HOME/.config" ]]; then
    log_info "✓ Dotfiles already deployed (symlinks detected). Skipping stow."
    return 0
  fi

  log_info "Deploying dotfiles with GNU Stow for the first time..."
  if stow --verbose=1 . 2>&1 | grep -v "^LINK" || true; then
    log_info "✓ Dotfiles deployed successfully!"
  else
    log_error "Stow failed, but check if some files were linked."
    return 1
  fi
}

# -----------------------------
# Main execution with error handling
# -----------------------------
main() {
  log_info "Starting bootstrap process..."
  echo ""

  # Run each step with error handling
  check_sudo || {
    log_error "Failed to get sudo privileges"
    exit 1
  }

  # Try to install packages, but continue even if it fails
  if install_packages; then
    log_info "✓ All packages installed successfully"
  else
    log_warn "Some packages failed to install, but continuing with deployment..."
  fi

  # Setup shell - warn but continue if fails
  if setup_zsh_shell; then
    log_info "✓ Shell configured successfully"
  else
    log_warn "Shell setup had issues, but continuing..."
  fi

  # Deploy dotfiles - this is critical
  deploy_dotfiles || {
    log_error "Dotfiles deployment failed"
    exit 1
  }

  echo ""
  log_info "=========================================="
  log_info "Bootstrap complete! 🎉"
  log_info "=========================================="
  log_info "Next steps:"
  log_info "1. Log out and log back in (or run 'exec zsh')"
  log_info "2. Your .zshrc will handle plugin installation automatically"
  log_info "3. Verify your shell: getent passwd $USER | cut -d: -f7"
}

# -----------------------------
# Allow running individual functions
# -----------------------------
if [[ $# -gt 0 ]]; then
  case "$1" in
  packages)
    check_sudo
    install_packages
    ;;
  shell)
    check_sudo
    setup_zsh_shell
    ;;
  stow)
    deploy_dotfiles
    ;;
  *)
    echo "Usage: $0 [packages|shell|stow]"
    echo "  packages    - Install required packages only"
    echo "  shell       - Setup zsh as default shell only"
    echo "  stow        - Deploy dotfiles only"
    echo ""
    echo "Run without arguments to execute full bootstrap."
    exit 1
    ;;
  esac
else
  main
fi
