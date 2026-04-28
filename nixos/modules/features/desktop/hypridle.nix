# Hyprland idle daemon
{
  flake.nixosModules.hypridle =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        hypridle
      ];
    };
}
