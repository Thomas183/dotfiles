# Wayland compositor (Hyprland) + audio (PipeWire) + XDG portal
{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.hyprland =
    { pkgs, inputs, lib, ... }:
    let

      cybrCyanThemes = pkgs.stdenv.mkDerivation {
        name = "cybrcyan-themes";
        src = pkgs.fetchFromGitHub {
          owner = "HasanAgitUnal";
          repo = "CybrCyanThemes";
          rev = "6e49bd70b5fc20e2c72d8d65d1c1134dc84b11c0";
          hash = "sha256-TcEtWb4qtk3GecUtTpUbE0kJUOz0eg3digrqN6b7Uxc=";
        };
        installPhase = ''
          mkdir -p $out/share/themes $out/share/icons
          cp -r CybrCyanMateria $out/share/themes/
          cp -r CybrCyanPapirus $out/share/icons/
        '';
      };
      
    in
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
        inotify-tools
        cybrCyanThemes
        unzip
        p7zip
        qt6.qtwayland
        qt5.qtwayland
      ];

      environment.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "24";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";

      };

      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = {
              "org/gnome/desktop/interface" = {
                gtk-theme = "CybrCyanMateria";
                icon-theme = "CybrCyanPapirus";
                cursor-theme = "Bibata-Modern-Ice";
                cursor-size = lib.gvariant.mkInt32 24;
                color-scheme = "prefer-dark";
              };
            };
          }
        ];
      };

      # security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      xdg.portal = {
        enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            ];
        };
    };
}
