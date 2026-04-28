# Composite terminal module: splits shell config and tools
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
