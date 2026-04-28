# Composite dev module: groups jetbrains, lamp, services, and tools
{ self, ... }:
{
  flake.nixosModules.dev =
    { ... }:
    {
      imports = [
        self.nixosModules.devJetbrains
        self.nixosModules.lamp
        self.nixosModules.devServices
        self.nixosModules.devTools
      ];
    };
}
