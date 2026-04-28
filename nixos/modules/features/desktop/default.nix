# Desktop environment (Hyprland + companions) - composes all desktop modules
{
  self,
  ...
}:
{
  flake.nixosModules.desktop =
    { ... }:
    {
      imports = [
        self.nixosModules.desktopCore
        self.nixosModules.hyprland
        self.nixosModules.hyprlock
        self.nixosModules.hypridle
        self.nixosModules.desktopTools
      ];
    };
}
