# ════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ════════════════════════════════════════════════════════════════

# Make directory and cd into it
mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

# Extract archives (auto-detect format)
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

# Go up N directories: up 3 = ../../../
up() {
  local count="${1:-1}"
  local path=""
  for _ in $(seq 1 "$count"); do
    path="../$path"
  done
  cd "$path" || return
}

# Fuzzy find directory and cd into it
fcd() {
  command -v fzf >/dev/null || return
  local dir
  dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m) && cd "$dir"
}

# Fuzzy search and re-execute command from history
fh() {
  command -v fzf >/dev/null || return
  local cmd
  cmd=$(fc -l 1 | fzf +s --tac | sed 's/ *[0-9]* *//') && eval "$cmd"
}

# Quick HTTP server on port (default 8000)
serve() {
  local port="${1:-8000}"
  echo "Serving at http://localhost:$port"
  python3 -m http.server "$port"
}

# Fetch .gitignore templates from toptal (BUG FIX: use "$@" for proper argument passing)
gi() { curl -sL "https://www.toptal.com/developers/gitignore/api/$*"; }

# Create backup copy of file: bak file.txt → file.txt.bak
bak() { cp "$1"{,.bak}; echo "Backup: $1.bak"; }

# Find process using port: fport 8000
fport() { lsof -i :"$1"; }

# Tree view with smart exclusions (BUG FIX: quoted "$@")
tre() { tree -aC -I '.git|node_modules|.DS_Store' --dirsfirst "$@"; }
