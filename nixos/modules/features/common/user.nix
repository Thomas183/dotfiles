# Base user definition shared by every host
{ self, ... }:
{
  flake.nixosModules.user =
    { ... }:
    {
      users.users.thomas = {
        isNormalUser = true;
        description = "thomas";
        extraGroups = [
          "networkmanager"
          "wheel"
          "input"
          "video"
          "render"
          "seat"
        ];
      };
    };
}
