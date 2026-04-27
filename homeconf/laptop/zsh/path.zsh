# ════════════════════════════════════════════════════════════════
# PATH CONFIGURATION
# ════════════════════════════════════════════════════════════════

# Ensure no duplicate entries in PATH
typeset -U PATH path
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)
export PATH
