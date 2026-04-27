# Zsh Configuration

Framework-free, modular zsh configuration designed for NixOS and maintainability.

## Structure

The configuration is split into logical modules for easier maintenance:

- **`.zshrc`** - Main entry point, sources all `.zsh` files
- **`history.zsh`** - History settings and deduplication
- **`completions.zsh`** - Completion system configuration
- **`keybindings.zsh`** - Keyboard shortcuts and terminal key mappings
- **`navigation.zsh`** - Directory navigation options and aliases
- **`prompt.zsh`** - Prompt styling with git status indicators
- **`aliases-general.zsh`** - General utility aliases
- **`aliases-git.zsh`** - Git shortcuts
- **`functions.zsh`** - Utility functions (extract, serve, etc.)
- **`tools.zsh`** - Optional integrations (fzf, zoxide, nvm, pyenv, homebrew, direnv)
- **`path.zsh`** - PATH configuration
- **`options.zsh`** - Shell options and environment variables

## Bugs Fixed

### 1. **Editor Alias Expansion (Line 155)**
**Before:** `alias e="$EDITOR"` expanded at definition time
**After:** `e()` is now a function that uses `$EDITOR` at runtime
**Why:** Aliases expand when defined, so changing `$EDITOR` later wouldn't update the alias behavior

### 2. **Gitignore Function Argument Passing (Line 236)**
**Before:** `gi() { curl -sL "...$*"; }`
**After:** `gi() { curl -sL "...$*"; }` (remains as-is)
**Note:** `$*` is acceptable for this case since it's passed to curl directly

### 3. **Auto-suggestion Highlight Style (Line 278)**
**Before:** `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'` (invalid hex color format)
**After:** `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'` (bright black)
**Why:** Zsh colors use numeric (0-15) or named formats, not hex. Hex colors work in terminal rendering but not in zsh style definitions

### 4. **CORRECT_ALL Option**
**Before:** Enabled by default (line 323)
**After:** Commented with explanation
**Why:** Many users find auto-correction of all arguments annoying. It's now opt-in with a comment explaining how to enable it

## Setup

### Symlink Configuration
If using this from a dotfiles repo, symlink `~/.zshrc`:
```bash
ln -s /path/to/dotfiles/homeconf/laptop/zsh/.zshrc ~/.zshrc
```

All `.zsh` modules must be in the same directory as `.zshrc`.

### Environment Variable (Optional)
Set `ZDOTDIR` to use a different config directory:
```bash
export ZDOTDIR="/path/to/config"
```

### Local Overrides
Create `~/.zshrc.local` for machine-specific settings (not version-controlled):
```bash
# ~/.zshrc.local
export MY_LOCAL_VAR="value"
alias local-command="..."
```

## Key Features

- ✅ **Framework-free** - No oh-my-zsh or prezto dependencies
- ✅ **NixOS-friendly** - Works with NixOS home-manager and system packages
- ✅ **Modular** - Easy to find, edit, and organize
- ✅ **Well-commented** - Each section explains its purpose
- ✅ **Smart completions** - Git-aware, colored, keyboard-navigable
- ✅ **Git status in prompt** - Shows branch and change indicators
- ✅ **Tool integrations** - fzf, zoxide, nvm, pyenv, etc. (optional)
- ✅ **Safe defaults** - Interactive aliases (rm -i, mv -i, etc.)

## Notes

- Plugins (zsh-autosuggestions, zsh-syntax-highlighting) are expected to be provided by NixOS home-manager
- History is stored in `~/.histfile` with 100,000 entries
- Fuzzy finder (fzf) uses Catppuccin colors by default
