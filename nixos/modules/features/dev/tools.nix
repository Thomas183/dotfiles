# Development packages, language runtimes, and editors
{ self, ... }:
{
  flake.nixosModules.devTools =
    { pkgs, config, lib, ... }:
    {
      environment.systemPackages =
        (with pkgs; [
          symfony-cli
          php85
          phpPackages.composer
          apacheHttpd
          nil
          nixd
          d2
          python315
          docker
          docker-client
          nodejs
          claude-code
          helix
        ])
        ++ lib.optionals (!config.myConfig.headless) (with pkgs; [
          zed-editor-fhs
          vscode-fhs
          filezilla
          gnome-builder
          figma-linux
          gnumake
        ]);
    };
}
