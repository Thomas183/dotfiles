# Applications shared across all hosts — CLI tools always, GUI tools only when not headless
{ self, ... }:
{
  flake.nixosModules.commonApps =
    { pkgs, config, lib, ... }:
    let
      # Enable VA-API hardware encoding for WebRTC streams (Discord/Vesktop).
      # Without these flags Electron uses software encoding, causing periodic freezes.
      vesktop-vaapi = pkgs.symlinkJoin {
        name = "vesktop";
        paths = [ pkgs.vesktop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/vesktop \
            --add-flags "--enable-features=VaapiVideoEncoder,VaapiVideoDecodeLinuxGL,CanvasOopRasterization" \
            --add-flags "--disable-features=UseChromeOSDirectVideoDecoder" \
            --add-flags "--enable-accelerated-video-encode" \
            --add-flags "--ignore-gpu-blocklist"
        '';
      };

      # CEF (embedded Chromium) inside jellyfin-desktop breaks on Wayland with Mesa 26.
      # Force XCB so Qt falls through to XWayland while other Qt apps stay on Wayland.
      jellyfin-desktop-xcb = pkgs.symlinkJoin {
        name = "jellyfin-desktop";
        paths = [ pkgs.jellyfin-desktop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/jellyfin-desktop \
            --set QT_QPA_PLATFORM xcb
        '';
      };
    in
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
          vesktop-vaapi
          discord
          obs-studio
          whatsapp-electron
          jellyfin-desktop-xcb
          spotify
          proton-pass
          proton-vpn
          protonmail-desktop
          parsec-bin
          moonlight
          qbittorrent
          mpv
          termius
        ]);
    };
}
