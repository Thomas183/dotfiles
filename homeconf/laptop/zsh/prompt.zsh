# ════════════════════════════════════════════════════════════════
# PROMPT CONFIGURATION
# ════════════════════════════════════════════════════════════════

autoload -Uz vcs_info
precmd_functions+=(vcs_info)
setopt PROMPT_SUBST

# Git status indicators
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr ' %F{red}●%f'      # Unstaged changes
zstyle ':vcs_info:git:*' stagedstr   ' %F{green}●%f'    # Staged changes
zstyle ':vcs_info:git:*' formats     ' %F{cyan}(%b%u%c%f%F{cyan})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}(%b|%a%u%c%f%F{yellow})%f'

# Main prompt: user@host ~/path (git-info)
# ❯ indicator
PROMPT='%F{green}%n%f%F{white}@%f%F{blue}%m%f %F{white}%~%f${vcs_info_msg_0_}
%F{magenta}❯%f '

# Right prompt: exit code on error
RPROMPT='%F{white}%(?..[%F{red}%?%f])%f'
