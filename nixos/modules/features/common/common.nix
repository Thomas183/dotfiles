# Composite common module: host options, base settings, user, apps, services
{ self, ... }:
{
  flake.nixosModules.common =
    { ... }:
    {
      imports = [
        self.nixosModules.hostOptions
        self.nixosModules.base
        self.nixosModules.user
        self.nixosModules.commonApps
        self.nixosModules.commonServices
      ];
    };
}
