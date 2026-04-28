# Desktop utilities and tools
{
  flake.nixosModules.desktopTools =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        waybar
        rofi
        cliphist
        dunst
        thunar
        quickshell
        unzip
        p7zip
      ];
    };
}
