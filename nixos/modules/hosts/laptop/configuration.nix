{ self, inputs, ... }:
{
  flake.nixosModules.laptopConfiguration =

    { config, pkgs, ... }:

    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.laptopHardware

        self.nixosModules.common
        self.nixosModules.terminal
        self.nixosModules.desktop
        self.nixosModules.gaming
        self.nixosModules.jetbrains
        self.nixosModules.services
        self.nixosModules.tools
        self.nixosModules.lamp
      ];

      services.lamp = {
        enable = true;
        user = "thomas";
      };

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client"; # or "server" / "both" for exit nodes
      };

      # Open the firewall for Tailscale
      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      nix.settings = {
        download-buffer-size = 524288000; # 500 MiB
      };

      programs.zsh.loginShellInit = ''
        if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
          exec start-hyprland
        fi
      '';

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
          "docker"
        ];
      };

      services.power-profiles-daemon.enable = true;

      # Boot & System

      services.getty.autologinUser = "thomas";

      nixpkgs.config.allowUnfree = true;

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

      time.timeZone = "Europe/Brussels";

      i18n.defaultLocale = "en_US.UTF-8";

      services.xserver.xkb = {
        layout = "be";
        variant = "";
      };

      console.keyMap = "be-latin1";

      system.stateVersion = "25.11"; # Did you read the comment?

    };
}
