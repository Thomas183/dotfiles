# Applications shared across all hosts (browsers, media, communication)
{
  self,
  ...
}:

{
  flake.nixosModules.commonApps =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wget
        gh
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
        inxi
      ];
    };
}
