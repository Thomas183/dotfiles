# Host-level toggle options (e.g. headless mode)
{ self, ... }:
{
  flake.nixosModules.hostOptions =
    { lib, ... }:
    {
      options.myConfig.headless = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "When true, GUI-dependent packages and services are excluded.";
      };
    };
}
