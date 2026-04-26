# dotfiles

Personal system configuration for two machines.

## Repo layout

```
dotfiles/
├── nixos-dots/   # NixOS flake — declarative system config for laptop & proxmoxMachine
└── homeconf/     # Manual dotfiles (zsh, hyprland, wezterm, etc.) — managed by hand
```

`homeconf/` contains user-level config files that are symlinked or copied manually. They are not managed by Home Manager and do not require any build step.

## nixos-dots

A [flake-parts](https://flake.parts/) flake using [import-tree](https://github.com/vic/import-tree) to auto-import all modules under `modules/`.

### Hosts

| Host | Description |
|------|-------------|
| `laptop` | AMD laptop, Hyprland on bare metal |
| `proxmoxMachine` | NVIDIA desktop running as a Proxmox VM, Hyprland via GPU passthrough |

### Feature modules (`modules/features/`)

| Module | Purpose |
|--------|---------|
| `common/common.nix` | Desktop apps shared across all hosts |
| `desktop/hyprland.nix` | Wayland compositor + audio + XDG portal |
| `terminal/wezterm.nix` | zsh + terminal emulator + CLI tools |
| `dev/tools.nix` | Development packages, language runtimes, editors |
| `dev/services.nix` | Docker + Portainer |
| `dev/lamp.nix` | Apache + MariaDB + PHP dev stack (NixOS module with options) |
| `dev/jetbrains.nix` | JetBrains IDEs |
| `gaming/gaming.nix` | Steam + Prism Launcher |

### Deploy

```bash
cd nixos-dots

# Laptop
sudo nixos-rebuild switch --flake .#laptop

# Proxmox machine
sudo nixos-rebuild switch --flake .#proxmoxMachine
```

### Validate without building

```bash
nix flake check
nix flake show
```

### Adding a new feature module

1. Create `modules/features/<category>/<name>.nix` with this structure:

```nix
# One-line description of what this module provides
{ self, ... }:
{
  flake.nixosModules.<name> =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ ... ];
    };
}
```

2. Import it in the relevant host's `configuration.nix`:

```nix
imports = [
  ...
  self.nixosModules.<name>
];
```

`import-tree` auto-discovers the file; no manual registration needed.
