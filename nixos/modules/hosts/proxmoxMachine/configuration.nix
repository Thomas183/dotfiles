{ self, inputs, ... }:
{
  flake.nixosModules.proxmoxMachineConfiguration =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {

      imports = [
        self.nixosModules.proxmoxMachineHardware

        self.nixosModules.hyprland
        self.nixosModules.terminal
        self.nixosModules.jetbrains
        self.nixosModules.services
        self.nixosModules.tools
        self.nixosModules.common
      ];

      swapDevices = [{
        device = "/swapfile";
        size = 16*1024;
      }];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      time.timeZone = "Europe/Brussels";
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "be-latin1";

      services.xserver.xkb = {
        layout = "be";
        variant = "";
      };


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

      ### Proxmox ###

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        WLR_NO_HARDWARE_CURSORS = "1";
      };

      programs.zsh.loginShellInit = ''
        if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
          exec Hyprland
        fi
      '';

      boot.kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
      ];

      boot.kernelModules = [ "uinput" ];

      services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660"
      '';

      services.getty.autologinUser = "thomas";

      services.tailscale.enable = true;

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = true;
      };

      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };

      services.seatd.enable = true;

      # NVIDIA #

      # Enable OpenGL
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      # Load nvidia driver for Xorg and Wayland
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {

        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
        # of just the bare essentials.
        powerManagement.enable = false;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      # Boot & Networking

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;
      networking.hostName = "proxmoxMachine";
      networking.networkmanager.enable = true;

      nixpkgs.config.allowUnfree = true;

      system.stateVersion = "26.05"; # DO NOT TOUCH WITHOUT READING DOC !!!

    };
}
