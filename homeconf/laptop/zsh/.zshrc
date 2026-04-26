# ═══════════════════════════════════════════════════════════════
#  ~/.zshrc — framework-free zsh configuration (NixOS-friendly)
# ═══════════════════════════════════════════════════════════════

# Skip if not interactive
[[ $- != *i* ]] && return


# ════════════════════════════════════════════════════════════════
# HISTORY
# ════════════════════════════════════════════════════════════════
HISTFILE="$HOME/.histfile"
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY


# ════════════════════════════════════════════════════════════════
# COMPLETION
# ════════════════════════════════════════════════════════════════
autoload -Uz compinit

# Rebuild completion dump once per day
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle :compinstall filename "$HOME/.zshrc"

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_LIST
setopt MENU_COMPLETE

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %d%f'
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'


# ════════════════════════════════════════════════════════════════
# KEY BINDINGS
# ════════════════════════════════════════════════════════════════
bindkey -e

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char


# ════════════════════════════════════════════════════════════════
# DIRECTORY NAVIGATION
# ════════════════════════════════════════════════════════════════
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt CDABLE_VARS

alias d='dirs -v'
for index in {1..9}; do
  alias "$index"="cd +${index}"
done


# ════════════════════════════════════════════════════════════════
# PROMPT
# ════════════════════════════════════════════════════════════════
autoload -Uz vcs_info
precmd_functions+=(vcs_info)
setopt PROMPT_SUBST

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr ' %F{red}●%f'
zstyle ':vcs_info:git:*' stagedstr   ' %F{green}●%f'
zstyle ':vcs_info:git:*' formats     ' %F{cyan}(%b%u%c%f%F{cyan})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}(%b|%a%u%c%f%F{yellow})%f'

PROMPT='%F{green}%n%f%F{white}@%f%F{blue}%m%f %F{white}%~%f${vcs_info_msg_0_}
%F{magenta}❯%f '
RPROMPT='%F{white}%(?..[%F{red}%?%f])%f'


# ════════════════════════════════════════════════════════════════
# ALIASES — GENERAL
# ════════════════════════════════════════════════════════════════

if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --group-directories-first --git'
  alias lt='eza --tree --icons --level=2'
  alias lta='eza --tree --icons --level=3'
else
  alias ls='ls --color=auto'
  alias ll='ls -lahF'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

if command -v bat &>/dev/null; then
  alias cat='bat --style=plain'
  alias cath='bat'
fi

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias df='df -h'
alias du='du -sh'
alias duh='du -h --max-depth=1 | sort -h'
alias free='free -h'
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me'

export EDITOR="${EDITOR:-vim}"
export VISUAL="$EDITOR"
alias e="$EDITOR"


# ════════════════════════════════════════════════════════════════
# ALIASES — GIT
# ════════════════════════════════════════════════════════════════
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate --all'
alias gll='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase'
alias gst='git stash'
alias gstp='git stash pop'
alias gundo='git reset --soft HEAD~1'


# ════════════════════════════════════════════════════════════════
# FUNCTIONS
# ════════════════════════════════════════════════════════════════

mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)  tar xjf "$1"   ;;
      *.tar.gz)   tar xzf "$1"   ;;
      *.tar.xz)   tar xJf "$1"   ;;
      *.tar)      tar xf "$1"    ;;
      *.bz2)      bunzip2 "$1"   ;;
      *.gz)       gunzip "$1"    ;;
      *.zip)      unzip "$1"     ;;
      *.7z)       7z x "$1"      ;;
      *.rar)      unrar x "$1"   ;;
      *.Z)        uncompress "$1";;
      *)          echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

up() {
  local count="${1:-1}"
  local path=""
  for _ in $(seq 1 "$count"); do
    path="../$path"
  done
  cd "$path" || return
}

fcd() {
  command -v fzf >/dev/null || return
  local dir
  dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m) && cd "$dir"
}

fh() {
  command -v fzf >/dev/null || return
  local cmd
  cmd=$(fc -l 1 | fzf +s --tac | sed 's/ *[0-9]* *//') && eval "$cmd"
}

serve() {
  local port="${1:-8000}"
  echo "Serving at http://localhost:$port"
  python3 -m http.server "$port"
}

gi() { curl -sL "https://www.toptal.com/developers/gitignore/api/$*"; }

bak() { cp "$1"{,.bak}; echo "Backup: $1.bak"; }

fport() { lsof -i :"$1"; }

tre() { tree -aC -I '.git|node_modules|.DS_Store' --dirsfirst "$@"; }


# ════════════════════════════════════════════════════════════════
# OPTIONAL TOOL INTEGRATIONS
# ════════════════════════════════════════════════════════════════

if command -v fzf &>/dev/null; then
  source <(fzf --zsh 2>/dev/null) || true

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

  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# autosuggestions/syntax-highlighting are enabled by NixOS in the module.
# Only set their options if the widget exists.
if (( $+widgets[autosuggest-accept] )); then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  bindkey '^ ' autosuggest-accept
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# pyenv
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Homebrew (optional)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi


# ════════════════════════════════════════════════════════════════
# PATH
# ════════════════════════════════════════════════════════════════
typeset -U PATH path
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)
export PATH


# ════════════════════════════════════════════════════════════════
# MISC OPTIONS
# ════════════════════════════════════════════════════════════════
setopt CORRECT
setopt CORRECT_ALL
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt EXTENDED_GLOB
setopt NULL_GLOB
setopt GLOB_DOTS

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
