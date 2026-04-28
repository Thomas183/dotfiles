# JetBrains IDEs (GUI only)
{ self, ... }:
{
  flake.nixosModules.devJetbrains =
    { pkgs, config, lib, ... }:
    {
      environment.systemPackages = lib.optionals (!config.myConfig.headless) (with pkgs; [
        jetbrains.phpstorm
        jetbrains.webstorm
        jetbrains.datagrip
        jetbrains.pycharm-oss
        jetbrains.idea
      ]);
    };
}
