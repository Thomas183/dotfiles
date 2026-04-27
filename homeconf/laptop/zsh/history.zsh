# ════════════════════════════════════════════════════════════════
# HISTORY CONFIGURATION
# ════════════════════════════════════════════════════════════════

HISTFILE="$HOME/.histfile"
HISTSIZE=100000
SAVEHIST=100000

# Deduplication
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE

# Optimization
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Sharing
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
