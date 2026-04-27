{
  self,
  ...
}:

{
  flake.nixosModules.lamp =
    # modules/lamp.nix
    {
      config,
      pkgs,
      lib,
      ...
    }:

    let
      cfg = config.services.lamp;
    in
    {
      # ── Module options ──────────────────────────────────────────────────────
      options.services.lamp = {
        enable = lib.mkEnableOption "LAMP development stack";

        user = lib.mkOption {
          type = lib.types.str;
          example = "alice";
          description = "Your normal user account. Apache and the working directory will be owned by this user.";
        };

        docRoot = lib.mkOption {
          type = lib.types.path;
          description = "Document root. Defaults to ~/www of the configured user.";
        };
      };

      # ── Implementation ──────────────────────────────────────────────────────
      config = lib.mkIf cfg.enable {

        # Safe default for docRoot — evaluated here in the config layer
        # where cfg.user is already fully resolved, avoiding infinite recursion
        services.lamp.docRoot = lib.mkDefault "/home/${cfg.user}/www";

        # ── PHP ─────────────────────────────────────────────────────────────
        # buildEnv is the canonical NixOS way to add extensions
        services.httpd.phpPackage = pkgs.php.buildEnv {
          extensions = (
            { enabled, all }:
            enabled
            ++ (with all; [
              mysqli
              mbstring
              zip
              gd
              intl
              curl
              bcmath
            ])
          );
        };

        # ── Apache ───────────────────────────────────────────────────────────
        services.httpd = {
          enable = true;
          enablePHP = true;
          adminAddr = "admin@localhost";

          # Run worker processes as the dev user — no wwwrun permission fights
          user = cfg.user;
          group = "users";

          virtualHosts."localhost" = {
            documentRoot = cfg.docRoot;
            extraConfig = ''
              # Show directory listing instead of a single index document
              <Directory "${cfg.docRoot}">
                Options Indexes FollowSymLinks
                AllowOverride All
                Require all granted
              </Directory>

              # Adminer at http://localhost/adminer
              Alias /adminer ${pkgs.adminer}/share/adminer
              <Directory "${pkgs.adminer}/share/adminer">
                Options None
                AllowOverride None
                DirectoryIndex adminer.php
                Require all granted
              </Directory>
            '';
          };
        };

        # Give the httpd systemd unit explicit read/write access to ~/www.
        # The module hardens the service with ReadWritePaths; home dirs are
        # outside the defaults, so we add it here explicitly.
        systemd.services.httpd.serviceConfig.ReadWritePaths = [ cfg.docRoot ];

        # ── MariaDB ──────────────────────────────────────────────────────────
        services.mysql = {
          enable = true;
          package = pkgs.mariadb;

          ensureDatabases = [ "dev" ];

          ensureUsers = [
            {
              name = cfg.user;
              ensurePermissions = {
                "*.*" = "ALL PRIVILEGES";
              };
            }
          ];
        };

        # ── Working directory ────────────────────────────────────────────────
        # Creates ~/www on boot if absent; mode 0755 lets Apache traverse it
        systemd.tmpfiles.rules = [
          "d ${cfg.docRoot} 0755 ${cfg.user} users -"
        ];
      };
    };
}
