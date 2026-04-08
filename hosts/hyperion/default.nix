{ inputs, self, ... }:
{
  flake = {
    nixosConfigurations.hyperion = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        inputs.nixos-wsl.nixosModules.default
        self.nixosModules.tailscale

        ./configuration.nix

        # profiles
        ../../profiles/common.nix
        #        ../../profiles/k3s.nix
        ../../profiles/k3s/kubectl.nix
        ../../profiles/nix.nix
        ../../profiles/secrets.nix

        # Users
        ../../users/root/common.nix
        ../../users/michael/common
        {
          home-manager.users.michael.imports = [
            self.homeModules.k8s-cluster-administration
          ];
        }
      ];
    };
  };
}
