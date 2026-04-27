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
      extractScript = pkgs.writeShellScriptBin "thunar-extract-subfolder" ''
        set -e
        archive="$1"
        dir="$(dirname "$archive")"
        base="$(basename "$archive")"
        case "$base" in
          *.tar.gz|*.tar.bz2|*.tar.xz|*.tar.zst) name="''${base%.*.*}" ;;
          *) name="''${base%.*}" ;;
        esac
        outdir="$dir/$name"
        mkdir -p "$outdir"
        case "$base" in
          *.zip|*.ZIP)       ${pkgs.unzip}/bin/unzip "$archive" -d "$outdir" ;;
          *.tar.gz|*.tgz)   tar xzf "$archive" -C "$outdir" ;;
          *.tar.bz2|*.tbz2) tar xjf "$archive" -C "$outdir" ;;
          *.tar.xz|*.txz)   tar xJf "$archive" -C "$outdir" ;;
          *.tar.zst)         tar --zstd -xf "$archive" -C "$outdir" ;;
          *.tar)             tar xf "$archive" -C "$outdir" ;;
          *.7z)              ${pkgs.p7zip}/bin/7z x "$archive" -o"$outdir" ;;
          *)
            echo "Unsupported archive: $base" >&2
            rmdir "$outdir" 2>/dev/null || true
            exit 1 ;;
        esac
      '';

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
        cybrCyanThemes
        extractScript
        unzip
        p7zip
      ];

      environment.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "24";
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

      system.userActivationScripts.thunarExtractAction = ''
        uca="$HOME/.config/Thunar/uca.xml"
        mkdir -p "$(dirname "$uca")"
        if [ ! -f "$uca" ]; then
          printf '<?xml version="1.0" encoding="UTF-8"?>\n<actions>\n</actions>\n' > "$uca"
        fi
        if ! grep -qF 'extract-subfolder-nixos-1' "$uca"; then
          sed -i 's|</actions>|<action>\n\t<icon>archive-extract</icon>\n\t<name>Extract to Subfolder</name>\n\t<submenu></submenu>\n\t<unique-id>extract-subfolder-nixos-1</unique-id>\n\t<command>thunar-extract-subfolder %f</command>\n\t<description>Extract archive to a folder of the same name</description>\n\t<range></range>\n\t<patterns>*.zip;*.ZIP;*.tar.gz;*.tar.bz2;*.tar.xz;*.tgz;*.tbz2;*.txz;*.tar;*.7z</patterns>\n\t<startup-notify/>\n\t<other-files/>\n</action>\n</actions>|' "$uca"
        fi
      '';

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
