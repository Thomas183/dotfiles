# Dev Composite Module

This directory groups developer-focused modules for easy import.

Modules:

- `default.nix` — Composite `dev` module that imports `jetbrains`, `lamp`, `services`, and `tools`.
- `jetbrains.nix`, `lamp.nix`, `services.nix`, `tools.nix` — Individual feature modules.

Usage:

Import the composite `dev` module in a host configuration:

```nix
imports = [ self.nixosModules.dev ];
```

Or import individual modules when you need only a subset.
