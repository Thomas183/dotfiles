# Wayland compositor: Hyprland
{ self, inputs, ... }:
{
  flake.nixosModules.hyprland =
    { pkgs, inputs, ... }:
    {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      environment.systemPackages = with pkgs; [
        hyprpaper
        kitty
        wl-clipboard
        inotify-tools
        qt6.qtwayland
        qt5.qtwayland
      ];

      programs.zsh.loginShellInit = ''
        if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
          exec start-hyprland
        fi
      '';
    };
}
