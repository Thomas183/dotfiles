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
      ];
    };
}
