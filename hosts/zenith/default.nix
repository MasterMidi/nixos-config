{ inputs, self, ... }:
rec {
  # imports = [ self.flake.flakeModules.deploy-rs ];
  flake = {
    nixosConfigurations.zenith = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        self.nixosModules.nix-builder
        self.nixosModules.k3s-node-agent
        self.nixosModules.hyprland

        ./services
        ./configuration.nix
        ./development.nix
        ./gaming.nix
        ./graphical.nix
        ./hardware.nix
        ./security.nix
        ./sound.nix
        ./system.nix
        ./virtualization.nix

        # profiles
        ../../profiles/common.nix
        ../../profiles/bare-metal.nix
        ../../profiles/mdns.nix
        ../../profiles/monitor-control.nix
        ../../profiles/nix.nix
        ../../profiles/secrets.nix
        ../../profiles/sound.nix
        ../../profiles/splash-screen.nix
        ../../profiles/vpn.nix

        # Users
        ../../users/root/common.nix
        ../../users/michael/zenith
        {
          home-manager.users.michael.imports = [
            self.homeModules.k8s-cluster-administration
            self.homeModules.hyprland
          ];
        }
      ];
    };
    diskoConfigurations.zenith = import ./disko.nix;
  };

  deploy.nodes.zenith = {
    hostname = "zenith";
    profiles.system = {
      sshUser = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos flake.nixosConfigurations.zenith;
      remoteBuild = true;
    };
  };
}
