# Composite dev module: groups jetbrains, lamp, services, and tools
{
  self,
  ...
}:
{
  flake.nixosModules.dev =
    { ... }:
    {
      imports = [
        self.nixosModules.jetbrains
        self.nixosModules.lamp
        self.nixosModules.services
        self.nixosModules.tools
      ];
    };
}
