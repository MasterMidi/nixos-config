{
  inputs,
  self,
  ...
}:
{
  flake = {
    nixosConfigurations.aether = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        inputs.srvos.nixosModules.server
        self.nixosModules.tailscale

        ./configuration.nix
        ./containers
        ./secrets
        ./disko.nix

        # profiles
        ../../profiles/common.nix
        self.nixosModules.nix
        self.nixosModules.sops
        # ../../profiles/vpn.nix

        # Users
        ../../users/root/common.nix
        ../../users/michael/server
      ];
    };
  };

  deploy.nodes.aether = {
    hostname = "aether";
    profiles.system = {
      sshUser = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.aether;
      remoteBuild = false;
    };
  };
}
