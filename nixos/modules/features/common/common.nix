# Desktop apps shared across all hosts (browsers, media, communication)
{
  self,
  ...
}:

{

  flake.nixosModules.common =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wget
        gh
        qutebrowser
        brave
        discord
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

      services.udisks2.enable = true;
      services.devmon.enable = true;
    };
}
