# Common Modules

This directory contains shared functionality used across hosts.

Modules:

- `common.nix` — Composite module that imports `commonApps` and `commonServices`.
- `apps.nix` — Desktop applications (browsers, media, communication).
- `services.nix` — System-level services enabled on most hosts (udisks2, devmon).

Usage:

Import the composite `common` module in a host configuration:

```nix
imports = [ self.nixosModules.common ];
```

If you prefer, import only the submodules:

```nix
imports = [
  self.nixosModules.commonApps,
  self.nixosModules.commonServices,
];
```
