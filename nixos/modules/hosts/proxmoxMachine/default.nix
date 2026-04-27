{ self, inputs, ... }:
{
  flake.nixosConfigurations.proxmoxMachine = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs self; };
    modules = [
      self.nixosModules.proxmoxMachineConfiguration
    ];
  };
}
