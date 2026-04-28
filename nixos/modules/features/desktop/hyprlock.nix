# Hyprland lock screen
{
  flake.nixosModules.hyprlock =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        hyprlock
      ];
    };
}
