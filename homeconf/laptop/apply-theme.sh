#!/usr/bin/env bash
# Reads colors.sh and regenerates all derived theme files, then signals apps to reload.
# Run manually or triggered automatically by watch-theme.sh on file save.

DOTS="$HOME/dotfiles/homeconf/laptop"
source "$DOTS/colors.sh"

# Strip leading # from a hex color
hex() { echo "${1#\#}"; }

# ── Hyprland colors.conf (fully regenerated) ────────────────────────────────
cat > "$DOTS/hypr/conf/colors.conf" << EOF
# CybrCyan palette — generated from colors.sh, do not edit manually
\$col_cyan   = rgba($(hex "$COLOR_CYAN")ee)
\$col_bg     = rgba($(hex "$COLOR_BG")ee)
\$col_muted  = rgba($(hex "$COLOR_MUTED")aa)
\$col_shadow = rgba(00000066)
EOF

# ── Rofi colors.rasi (fully regenerated) ────────────────────────────────────
cat > "$DOTS/rofi/colors.rasi" << EOF
/* CybrCyan palette — generated from colors.sh, do not edit manually */
* {
    bg:              $COLOR_BG;
    bg-alt:          $COLOR_BG_ALT;
    bg-sel:          ${COLOR_CYAN}26;
    border-col:      $COLOR_CYAN;
    fg:              $COLOR_FG;
    fg-sel:          $COLOR_CYAN_BRIGHT;
    placeholder-col: $COLOR_MUTED;
}
EOF

# ── WezTerm colors.lua (fully regenerated, WezTerm auto-reloads) ─────────────
cat > "$DOTS/wezterm/colors.lua" << EOF
-- CybrCyan palette — generated from colors.sh, do not edit manually
return {
    foreground    = "$COLOR_FG",
    background    = "$COLOR_BG",
    cursor_bg     = "$COLOR_CYAN",
    cursor_fg     = "$COLOR_BG",
    cursor_border = "$COLOR_CYAN",
    selection_fg  = "$COLOR_FG",
    selection_bg  = "#0d3040",
    ansi = {
        "$COLOR_BG",           -- black
        "$COLOR_RED",          -- red
        "$COLOR_GREEN",        -- green
        "$COLOR_YELLOW",       -- yellow
        "$COLOR_BLUE",         -- blue
        "$COLOR_PURPLE",       -- magenta
        "$COLOR_CYAN",         -- cyan
        "$COLOR_FG",           -- white
    },
    brights = {
        "$COLOR_MUTED",        -- bright black
        "#ff7a93",             -- bright red
        "#b9f27c",             -- bright green
        "#ff9e64",             -- bright yellow
        "#82aaff",             -- bright blue
        "#c099ff",             -- bright magenta
        "$COLOR_CYAN_BRIGHT",  -- bright cyan
        "#ffffff",             -- bright white
    },
}
EOF

# ── Quickshell shell.qml — update color properties in place ─────────────────
# Quickshell watches QML files and hot-reloads on changes.
QML="$DOTS/quickshell/shell.qml"
# All substitutions in one sed pass = one file write = one Quickshell reload
# Pattern matches any quoted value so it survives named colors or prior corruption
sed -i -E \
    -e "s|(colBg:[[:space:]]+\")[^\"]*(\")|\1$COLOR_BG\2|" \
    -e "s|(colFg:[[:space:]]+\")[^\"]*(\")|\1$COLOR_FG\2|" \
    -e "s|(colMuted:[[:space:]]+\")[^\"]*(\")|\1$COLOR_MUTED\2|" \
    -e "s|(colCyan:[[:space:]]+\")[^\"]*(\")|\1$COLOR_CYAN\2|" \
    -e "s|(colPurple:[[:space:]]+\")[^\"]*(\")|\1$COLOR_PURPLE\2|" \
    -e "s|(colRed:[[:space:]]+\")[^\"]*(\")|\1$COLOR_RED\2|" \
    -e "s|(colYellow:[[:space:]]+\")[^\"]*(\")|\1$COLOR_YELLOW\2|" \
    -e "s|(colBlue:[[:space:]]+\")[^\"]*(\")|\1$COLOR_BLUE\2|" \
    "$QML"

# ── Reload signals ───────────────────────────────────────────────────────────
hyprctl reload                    # picks up colors.conf
# WezTerm auto-reloads on colors.lua change
# Quickshell auto-reloads on shell.qml change

dunstify "Theme reloaded" "CybrCyan palette applied" -i dialog-information -t 2000
