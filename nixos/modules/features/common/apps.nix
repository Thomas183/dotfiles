# Applications shared across all hosts — CLI tools always, GUI tools only when not headless
{ self, ... }:
{
  flake.nixosModules.commonApps =
    { pkgs, config, lib, ... }:
    {
      environment.systemPackages =
        (with pkgs; [
          wget
          gh
          inxi
        ])
        ++ lib.optionals (!config.myConfig.headless) (with pkgs; [
          qutebrowser
          brave
          vesktop
          discord
          obs-studio
          whatsapp-electron
          jellyfin-desktop
          spotify
          proton-pass
          protonvpn-gui
          protonmail-desktop
          parsec-bin
          moonlight
          qbittorrent
          mpv
          termius
        ]);
    };
}
