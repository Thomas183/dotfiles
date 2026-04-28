# Docker + Portainer container management
{ self, ... }:
{
  flake.nixosModules.devServices =
    { pkgs, ... }:
    {
      virtualisation.docker.enable = true;

      users.users.thomas.extraGroups = [ "docker" ];

      virtualisation.oci-containers = {
        backend = "docker";
        containers = {
          portainer = {
            image = "portainer/portainer-ce:latest";
            ports = [
              "8000:8000"
              "9443:9443"
            ];
            volumes = [
              "/var/run/docker.sock:/var/run/docker.sock"
              "portainer_data:/data"
            ];
          };
        };
      };
    };
}
