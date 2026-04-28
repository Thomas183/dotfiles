{ self, inputs, ... }:
{
  flake.nixosModules.laptopConfiguration =

    { config, pkgs, ... }:

    {
      imports = [
        self.nixosModules.laptopHardware
        self.nixosModules.common
        self.nixosModules.terminal
        self.nixosModules.desktop
        self.nixosModules.gaming
        self.nixosModules.dev
      ];

      services.lamp = {
        enable = true;
        user = "thomas";
      };

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
      };

      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      nix.settings.download-buffer-size = 524288000; # 500 MiB

      services.power-profiles-daemon.enable = true;

      environment.systemPackages = with pkgs; [
        networkmanagerapplet
        brightnessctl
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "laptop";
      networking.wireless.enable = true;
      networking.networkmanager.enable = true;

      system.stateVersion = "25.11"; # Did you read the comment?
    };
}
