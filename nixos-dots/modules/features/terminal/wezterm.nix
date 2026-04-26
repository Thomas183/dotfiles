# Shell (zsh) + terminal emulator + CLI tools
{
  self,
  ...
}:

{

  flake.nixosModules.terminal =
    { pkgs, ... }:
    {

      programs.zsh.enable = true;
      programs.zsh.autosuggestions.enable = true;
      programs.zsh.syntaxHighlighting.enable = true;
      users.defaultUserShell = pkgs.zsh;

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
