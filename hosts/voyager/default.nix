{
  inputs,
  self,
  ...
}:
{
  flake = {
    nixosConfigurations.voyager = inputs.nixos-raspberrypi.lib.nixosInstaller {
      specialArgs = {
        inherit inputs self;
        inherit (inputs) nixos-raspberrypi;
      };
      modules = [
        ./configuration.nix
        ./system.nix
        # ./home-assistant.nix
        {
          # Hardware specific configuration, see section below for a more complete
          # list of modules
          imports = with inputs.nixos-raspberrypi.nixosModules; [
            raspberry-pi-3.base
          ];
        }

        # profiles
        ../../profiles/common.nix
        ../../profiles/nix.nix
        ../../profiles/secrets.nix
        ../../profiles/vpn.nix
        ../../profiles/k3s.nix

        # Users
        ../../users/root/common.nix
        ../../users/michael/server
      ];
    };
  };

  deploy.nodes.voyager = {
    hostname = "voyager";
    profiles.system = {
      sshUser = "root";
      path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.voyager;
      remoteBuild = true;
    };
  };
}
