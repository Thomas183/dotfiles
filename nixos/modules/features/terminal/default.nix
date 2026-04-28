# Composite terminal module: shell config and CLI/GUI tools
{
  self,
  ...
}:

{
  flake.nixosModules.terminal =
    { ... }:
    {
      imports = [
        self.nixosModules.terminalShell
        self.nixosModules.terminalTools
      ];
    };
}
