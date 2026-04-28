# Composite common module: separates apps and system services
{
  self,
  ...
}:

{
  flake.nixosModules.common =
    { ... }:
    {
      imports = [
        self.nixosModules.commonApps
        self.nixosModules.commonServices
      ];
    };
}
