{
  self,
  ...
}:

{

  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        steam
        prismlauncher
      ];
    };
}
