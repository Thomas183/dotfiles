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

      hardware.bluetooth = {
        enable      = true;
        powerOnBoot = true;
      };

      # The ideapad_laptop platform driver soft-blocks BT via its own rfkill
      # switch at boot. The RTL8852BE also re-enumerates after firmware upload,
      # so bluetoothd may start before the controller is ready — both cause
      # "set mode: Failed (0x03)" and hci0 never initialises.
      # ExecStartPre clears the ideapad rfkill block; Restart+RestartSec handle
      # the USB re-enumeration race by retrying if the first attempt fails.
      systemd.services.bluetooth.serviceConfig = {
        # 1. Unblock the ideapad_laptop rfkill switch before starting.
        # 2. Sleep 5 s: the RTL8852BE takes ~4 s to finish firmware upload
        #    after btusb loads; bluetoothd must not send MGMT commands before
        #    the chip is fully ready or SET_DEFAULT_SYSTEM_CONFIG fails and
        #    the adapter is never registered (service stays "running" silently).
        ExecStartPre = [
          "${pkgs.util-linux}/bin/rfkill unblock bluetooth"
          "${pkgs.coreutils}/bin/sleep 5"
        ];
        Restart    = "on-failure";
        RestartSec = "3s";
      };

      # Realtek RTL8852BE BT (0bda:4853) enters USB autosuspend and becomes
      # unresponsive on ThinkBook — disable it for this adapter specifically.
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="4853", ATTR{power/autosuspend}="-1"
      '';

      hardware.graphics = {
        enable = true;
	enable32Bit = true;
        extraPackages = with pkgs; [
          mesa
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };

      services.power-profiles-daemon.enable = true;

      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          libx11
          libxext
          libxrender
          libxtst
          libxi
          libxfixes
          libxcursor
          libxrandr
          libxcb
          freetype
          fontconfig
          zlib
          libGL
          glib
          gtk3
          pango
          cairo
          atk
          nss
          nspr
          dbus
          expat
          libdrm
          alsa-lib
          cups
          at-spi2-core
          libxkbcommon
          libxcomposite
          libxdamage
          libudev-zero
          libgbm
        ];
      };

      environment.systemPackages = with pkgs; [
        networkmanagerapplet
        brightnessctl
        libva-utils
        ddcutil
        firefox
        chromium
        jdk25
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "laptop";
      networking.wireless.enable = true;
      networking.networkmanager.enable = true;

      networking.localCommands = ''
        ip route add 10.10.10.0/24 via 192.168.129.0 || true
      '';


      system.stateVersion = "25.11"; # Did you read the comment?
    };
}
