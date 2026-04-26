{
  self,
  inputs,
  ...
}:
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
        hyprlock
        hypridle
        waybar
        kitty
        rofi
        cliphist
        wl-clipboard
        dunst
        thunar
        bibata-cursors
        quickshell
      ];

      environment.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "24";
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = "*";
      };
    };
}
