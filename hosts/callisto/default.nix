{
  inputs,
  self,
  ...
}:
{
  flake = {
    nixosConfigurations.callisto = inputs.nixos-raspberrypi.lib.nixosSystem {
      specialArgs = {
        inherit inputs self;
        inherit (inputs) nixos-raspberrypi;
      };
      modules = [
        ./configuration.nix
        ./config.nix
        {
          # Hardware specific configuration, see section below for a more complete
          # list of modules
          imports = with inputs.nixos-raspberrypi.nixosModules; [
            raspberry-pi-5.base
            raspberry-pi-5.page-size-16k
            raspberry-pi-5.display-vc4
            raspberry-pi-5.bluetooth
          ];
        }
        # ./containers
        # ./secrets
        # ./disko.nix

        # profiles
        ../../profiles/common.nix
        ../../profiles/nix.nix
        ../../profiles/secrets.nix
        ../../profiles/vpn.nix

        # Users
        ../../users/root/common.nix
        ../../users/michael/server
      ];
    };
  };

  deploy.nodes.callisto = {
    hostname = "callisto";
    profiles.system = {
      sshUser = "root";
      path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.callisto;
      remoteBuild = true;
    };
  };
}
