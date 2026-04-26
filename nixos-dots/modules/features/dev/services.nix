{
  self,
  ...
}:
{
  flake.nixosModules.services =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        tailscale
      ];

      virtualisation.docker.enable = true;

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
