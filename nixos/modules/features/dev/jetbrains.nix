# JetBrains IDEs (PhpStorm, WebStorm, DataGrip, PyCharm)
{
  self,
  ...
}:

{

  flake.nixosModules.jetbrains =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        jetbrains.phpstorm
        jetbrains.webstorm
        jetbrains.datagrip
        jetbrains.pycharm-oss
        jetbrains.idea
      ];
    };
}
