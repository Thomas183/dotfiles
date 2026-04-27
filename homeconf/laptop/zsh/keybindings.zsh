# ════════════════════════════════════════════════════════════════
# KEY BINDINGS
# ════════════════════════════════════════════════════════════════

bindkey -e

# History search with prefix matching
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search      # Up arrow
bindkey "^[[B" down-line-or-beginning-search    # Down arrow
bindkey "^[OA" up-line-or-beginning-search      # Alternative up
bindkey "^[OB" down-line-or-beginning-search    # Alternative down

# Word navigation (Ctrl+Left/Right)
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Home/End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Delete key
bindkey "^[[3~" delete-char
