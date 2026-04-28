# CLI tools (always) and terminal emulator (GUI hosts only)
{ self, ... }:
{
  flake.nixosModules.terminalTools =
    { pkgs, config, lib, ... }:
    {
      environment.systemPackages =
        (with pkgs; [
          fastfetch
          yazi
          micro
          htop

          # tools used by your zsh config
          eza
          bat
          fzf
          fd
          zoxide
          direnv
          tree
          git
          curl
          lsof
          unzip
          p7zip
          iproute2
          unrar
          pciutils
        ])
        ++ lib.optionals (!config.myConfig.headless) (with pkgs; [
          wezterm
        ]);
    };
}
