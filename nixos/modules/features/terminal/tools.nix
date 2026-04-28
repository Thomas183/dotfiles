# Terminal emulator and CLI tools
{
  self,
  ...
}:

{
  flake.nixosModules.terminalTools =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wezterm
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
      ];
    };
}
