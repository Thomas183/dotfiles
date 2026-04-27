# ═══════════════════════════════════════════════════════════════
#  ~/.zshrc — framework-free zsh configuration (NixOS-friendly)
# ═══════════════════════════════════════════════════════════════

# Skip if not interactive
[[ $- != *i* ]] && return

# Resolve the directory where .zshrc lives (handles symlinks)
if [[ -L "$HOME/.zshrc" ]]; then
  _zsh_config_dir="$(cd "$(dirname "$(readlink -f "$HOME/.zshrc")")" && pwd)"
else
  _zsh_config_dir="$(cd "$(dirname "$HOME/.zshrc")" && pwd)"
fi

# Source modular configs in order
for file in "$_zsh_config_dir"/*.zsh; do
  [[ -f "$file" ]] && source "$file"
done
unset _zsh_config_dir

# Local overrides (not version-controlled)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
