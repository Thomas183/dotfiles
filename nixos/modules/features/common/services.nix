# System-level services used across hosts
{
  self,
  ...
}:

{
  flake.nixosModules.commonServices =
    { ... }:
    {
      services.udisks2.enable = true;
      services.devmon.enable = true;
    };
}
