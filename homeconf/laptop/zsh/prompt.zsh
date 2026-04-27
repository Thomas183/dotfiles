# ════════════════════════════════════════════════════════════════
# PROMPT CONFIGURATION
# ════════════════════════════════════════════════════════════════

autoload -Uz vcs_info
precmd_functions+=(vcs_info)
setopt PROMPT_SUBST

# Git status indicators
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr ' %F{red}●%f'       # Unstaged changes
zstyle ':vcs_info:git:*' stagedstr   ' %F{green}●%f'     # Staged changes
zstyle ':vcs_info:git:*' formats     ' %F{cyan}(%b%u%c%f%F{cyan})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}(%b|%a%u%c%f%F{yellow})%f'

# Main prompt: user@host ~/path (git-info)
# ❯ indicator — CybrCyan palette
PROMPT='%F{cyan}%n%f%F{245}@%f%F{cyan}%m%f %F{white}%~%f${vcs_info_msg_0_}
%F{cyan}❯%f '

# Right prompt: exit code on error
RPROMPT='%F{245}%(?..[%F{red}%?%f])%f'
