# Development packages, language runtimes, and editors
{
  self,
  ...
}:

{

  flake.nixosModules.tools =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        symfony-cli
        php85
        apacheHttpd
        nil
        nixd
        d2
        python315
        zed-editor-fhs
        vscode-fhs
        docker
        filezilla
        docker-client
        gnome-builder
        nodejs
        figma-linux
        claude-code
      ];
    };
}
