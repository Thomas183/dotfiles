# ════════════════════════════════════════════════════════════════
# OPTIONAL TOOL INTEGRATIONS
# ════════════════════════════════════════════════════════════════

# FZF (fuzzy finder) configuration
if command -v fzf &>/dev/null; then
  source <(fzf --zsh 2>/dev/null) 2>/dev/null || true

  export FZF_DEFAULT_OPTS="
    --height=40%
    --layout=reverse
    --border=rounded
    --preview-window=right:50%:wrap
    --color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa
    --color=fg+:#cdd6f4,bg+:#313244,hl+:#89b4fa
    --color=info:#cba6f7,prompt:#cba6f7,pointer:#f5c2e7
    --color=marker:#a6e3a1,spinner:#f5c2e7,header:#89b4fa
  "

  # Use fd (faster than find) if available
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi

# Zoxide (smarter cd replacement)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# NVM (Node version manager) - lazy loading
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Pyenv (Python version manager)
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Homebrew (macOS/Linux)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Direnv (automatic environment switching)
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# Zsh auto-suggestion (enabled by NixOS module by default)
# Only configure if the widget is available
if (( $+widgets[autosuggest-accept] )); then
  # BUG FIX: Use valid zsh color (8 = bright black) instead of hex #6c7086
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  bindkey '^ ' autosuggest-accept
fi
