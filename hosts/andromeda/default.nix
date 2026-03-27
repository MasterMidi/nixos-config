{
  inputs,
  self,
  ...
}:
{
  flake = {
    nixosConfigurations.andromeda = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        self.nixosModules.k8s-longhorn
        self.nixosModules.k3s-node-server
        self.nixosModules.k3s-gpu-nvidia
        self.nixosModules.tailscale
        self.nixosModules.nix-builder

        ./configuration.nix
        ./containers
        ./hardware.nix
        ./secrets
        ./home-assistant.nix

        # profiles
        ../../profiles/common.nix
        ../../profiles/bare-metal.nix
        ../../profiles/mdns.nix
        ../../profiles/nix.nix
        ../../profiles/secrets.nix

        # Users
        ../../users/root/common.nix
        ../../users/michael/server
      ];
    };

  };

  deploy.nodes.andromeda = {
    hostname = "andromeda";
    profiles.system = {
      sshUser = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.andromeda;
      remoteBuild = true;
    };
  };
}
