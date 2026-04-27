# ════════════════════════════════════════════════════════════════
# DIRECTORY NAVIGATION
# ════════════════════════════════════════════════════════════════

setopt AUTO_CD           # cd into directories without typing 'cd'
setopt AUTO_PUSHD        # Automatically push directories to stack
setopt PUSHD_IGNORE_DUPS # Don't duplicate in stack
setopt PUSHD_SILENT      # Don't print stack on cd
setopt CDABLE_VARS       # Can use variables in cd

# Quick directory shortcuts: '1' = cd +1, '2' = cd +2, etc.
alias d='dirs -v'
for index in {1..9}; do
  alias "$index"="cd +${index}"
done
