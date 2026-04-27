# ════════════════════════════════════════════════════════════════
# MISCELLANEOUS OPTIONS & ENVIRONMENT
# ════════════════════════════════════════════════════════════════

# Command correction (WARNING: CORRECT_ALL can be annoying, consider disabling)
setopt CORRECT
# setopt CORRECT_ALL  # Uncomment if you want auto-correction for all arguments

# General shell options
setopt INTERACTIVE_COMMENTS  # Allow comments in interactive shell
setopt NO_BEEP              # Disable terminal bell
setopt EXTENDED_GLOB        # Extended globbing patterns
setopt NULL_GLOB            # Don't error on failed glob
setopt GLOB_DOTS            # Include dotfiles in glob patterns

# Man page colors (less pager)
export LESS_TERMCAP_mb=$'\e[1;32m'  # Blinking
export LESS_TERMCAP_md=$'\e[1;32m'  # Bold
export LESS_TERMCAP_me=$'\e[0m'     # End
export LESS_TERMCAP_se=$'\e[0m'     # End standout
export LESS_TERMCAP_so=$'\e[01;33m' # Standout
export LESS_TERMCAP_ue=$'\e[0m'     # End underline
export LESS_TERMCAP_us=$'\e[1;4;31m'# Underline
