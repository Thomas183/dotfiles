# JetBrains IDEs (GUI only) - idea managed via Flatpak
{ self, ... }:
{
  flake.nixosModules.devJetbrains =
    { pkgs, config, lib, ... }:
    lib.mkIf (!config.myConfig.headless) {
      environment.systemPackages = with pkgs; [
        jetbrains.phpstorm
        jetbrains.webstorm
        jetbrains.datagrip
        jetbrains.pycharm-oss
      ];
    };
}
