# Zsh configuration (split from previous terminal module)
{
  self,
  ...
}:

{
  flake.nixosModules.terminalShell =
    { pkgs, ... }:
    {
      programs.zsh.enable = true;
      programs.zsh.autosuggestions.enable = true;
      programs.zsh.syntaxHighlighting.enable = true;
      users.defaultUserShell = pkgs.zsh;
    };
}
