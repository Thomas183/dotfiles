# ════════════════════════════════════════════════════════════════
# ALIASES — GENERAL
# ════════════════════════════════════════════════════════════════

# List directory contents with eza or fallback to ls
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --group-directories-first --git'
  alias lt='eza --tree --icons --level=2'
  alias lta='eza --tree --icons --level=3'
else
  alias ls='ls --color=auto'
  alias ll='ls -lahF'
fi

# Parent directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safe defaults (interactive mode)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Syntax highlighting for cat
if command -v bat &>/dev/null; then
  alias cat='bat --style=plain'
  alias cath='bat'
fi

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Human-readable utilities
alias df='df -h'
alias du='du -sh'
alias duh='du -h --max-depth=1 | sort -h'
alias free='free -h'
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me'

# Editor: use as a function to support runtime EDITOR changes
e() { "${EDITOR:-vim}" "$@"; }
export EDITOR="${EDITOR:-vim}"
export VISUAL="$EDITOR"
