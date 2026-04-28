# Base desktop environment: audio, portals, themes, and session variables
{ self, ... }:
{
  flake.nixosModules.desktopCore =
    { lib, pkgs, ... }:
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
      # Audio: PipeWire replaces PulseAudio
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      # XDG Desktop Portal: required for file dialogs, screen sharing, etc.
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };

      # Theme and cursor settings
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

      # Environment variables for Wayland
      environment.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "24";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
      };

      # Common desktop packages
      environment.systemPackages = with pkgs; [
        bibata-cursors
        cybrCyanThemes
      ];
    };
}
