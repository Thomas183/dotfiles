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
        git
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
      ];

      services.udisks2.enable = true;
      services.devmon.enable = true;
    };
}
