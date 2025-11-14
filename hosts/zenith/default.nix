{ inputs, self, ... }:
{
  # imports = [ self.flake.flakeModules.deploy-rs ];
  flake = {
    nixosConfigurations.zenith = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
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
        ../../profiles/k3s.nix
        ../../profiles/mdns.nix
        ../../profiles/nix.nix
        ../../profiles/secrets.nix
        ../../profiles/sound.nix
        ../../profiles/splash-screen.nix
        ../../profiles/vpn.nix

        # Users
        ../../users/root/common.nix
        ../../users/michael/zenith.nix
      ];
    };
    diskoConfigurations.zenith = import ./disko.nix;
  };

  deploy.nodes.zenith = {
    hostname = "zenith";
    profiles.system = {
      sshUser = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zenith;
      remoteBuild = true;
    };
  };
}
