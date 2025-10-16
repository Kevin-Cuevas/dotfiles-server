# ===============================================================================
# ZSH CONFIGURATION
# ===============================================================================

export TERM=xterm-256color

# Zona horaria
export LC_TIME="en_US.UTF-8"

# ===============================================================================
# ENABLE POWERLEVEL10K 
# ===============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===============================================================================
# ZINIT SETUP
# ===============================================================================

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# ===============================================================================
# ZSH PLUGINS
# ===============================================================================

# Essential plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add PowerLevel10k 
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Oh My Zsh snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# Load completions
autoload -U compinit && compinit
zinit cdreplay -q

# ===============================================================================
# ENVIRONMENT VARIABLES & PATHS
# ===============================================================================

# Editor settings
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Custom paths
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/sbin:/usr/sbin

# ===============================================================================
# HISTORY CONFIGURATION
# ===============================================================================

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
HISTDUP=erase

# History options
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ===============================================================================
# COMPLETION STYLING
# ===============================================================================

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa --icons --group-directories-first --color=auto $realpath'

# ===============================================================================
# CUSTOM FUNCTIONS
# ===============================================================================

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ===============================================================================
# ALIASES
# ===============================================================================

# File listing
alias ls="eza --icons --group-directories-first --color=auto"
alias ll="eza -lah --icons --group-directories-first"
alias lt="eza -T --level=2 --icons --group-directories-first"
alias ..='cd ..'
alias mkdir='mkdir -p'

# Development tools
alias fvim='nvim -u NONE'

# Utilities
alias bat="batcat"
alias vim="nvim"

# ===============================================================================
# SHELL INTEGRATIONS
# ===============================================================================

# Python virtual environment auto-activation
if [ -f "./venv/bin/activate" ]; then
  source ./venv/bin/activate
elif [ -f "./.venv/bin/activate" ]; then
  source ./.venv/bin/activate
fi

# FZF setup
export PATH="$HOME/.fzf/bin:$PATH"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide (enhanced cd)
eval "$(zoxide init zsh)"
zstyle ':fzf-tab:complete:z:*' fzf-preview \
  'target="$(zoxide query -- "$word" 2>/dev/null || printf "%s" "$word")"; \
   exa --icons --group-directories-first --color=auto "$target"'

# ===============================================================================
# KEYBINDINGS
# ===============================================================================

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ===============================================================================
# PROMPT INITIALIZATION
# ===============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===============================================================================
# LOAD MORE CONFIG 
# ===============================================================================

if [ -f "${ZDOTDIR:-$HOME}/.zshrc-local" ]; then
  source "${ZDOTDIR:-$HOME}/.zshrc-local"
fi
