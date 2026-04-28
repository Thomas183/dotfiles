# Locale, nix settings, and autologin shared by every host
{ self, ... }:
{
  flake.nixosModules.base =
    { ... }:
    {
      time.timeZone = "Europe/Brussels";
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "be-latin1";

      services.xserver.xkb = {
        layout = "be";
        variant = "";
      };

      nixpkgs.config.allowUnfree = true;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      services.getty.autologinUser = "thomas";
    };
}
