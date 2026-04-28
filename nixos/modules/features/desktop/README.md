# Desktop Environment Modules

This directory contains modular NixOS configurations for a Wayland desktop environment based on Hyprland.

## Module Structure

The desktop environment is composed of several focused modules that can be imported individually or together through the `desktop` composite module.

### Core Modules

- **`default.nix`** - The main desktop module that composes all sub-modules. Import this in your host configuration to get a complete desktop setup.
  
- **`core.nix`** - Base desktop infrastructure
  - PipeWire audio system
  - XDG desktop portal
  - Theme configuration (dconf, gtk, cursors)
  - Session environment variables
  - Shared theming packages

- **`hyprland.nix`** - Wayland compositor
  - Hyprland window manager
  - XWayland support
  - Core Wayland utilities (cliphist, wl-clipboard)
  - Qt Wayland support

- **`hyprlock.nix`** - Lock screen
  - Hyprlock package for screen locking

- **`hypridle.nix`** - Idle daemon management
  - Hypridle package
  - Configuration goes in `~/.config/hypridle/hypridle.conf`

- **`tools.nix`** - Desktop utilities
  - Waybar (status bar)
  - Rofi (application launcher)
  - Dunst (notifications)
  - Thunar (file manager)
  - Quickshell (system shell)
  - Archive tools

## Usage

### Import Everything

```nix
imports = [
  self.nixosModules.desktop
];
```

### Import Specific Modules

```nix
imports = [
  self.nixosModules.desktopCore    # Base only
  self.nixosModules.hyprland       # Just compositor
  self.nixosModules.desktopTools   # Just tools
];
```

## Configuration Files

### Hypridle Configuration

Hypridle is configured via `~/.config/hypridle/hypridle.conf`. Example:

```
general {
  lock_cmd = "pidof hyprlock || hyprlock"
  before_sleep_cmd = "loginctl lock-session"
  after_sleep_cmd = "hyprctl dispatch dpms on"
}

listener {
  timeout = 300
  on-timeout = "hyprlock"
}

listener {
  timeout = 600
  on-timeout = "hyprctl dispatch dpms off"
  on-resume = "hyprctl dispatch dpms on"
}
```

## Benefits

- **Modularity**: Each component can be enabled/disabled independently
- **Clarity**: Clear separation of concerns makes maintenance easier
- **Flexibility**: Mix and match components for different host configurations
- **Reusability**: Components can be reused across different hosts (laptop, workstation, etc.)
- **NixOS-native**: Configuration is pure NixOS, no home-manager dependency required
