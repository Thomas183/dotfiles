# Terminal Modules

This feature splits terminal-related configuration into focused modules:

- `wezterm.nix` — Composite `terminal` module that imports `terminalShell` and `terminalTools`.
- `shell.nix` — Zsh configuration (enables zsh and relevant plugins/features).
- `tools.nix` — Terminal emulator and CLI utilities (wezterm, htop, fzf, etc.).

Usage:

Import the top-level `terminal` module in host configs (no changes needed):

```nix
imports = [ self.nixosModules.terminal ];
```

Or import only a submodule when you want a subset:

```nix
imports = [ self.nixosModules.terminalTools ];
```
