{ inputs, self, ... }:
{
  flake = {
    nixosConfigurations.meridian = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        inputs.nixos-hardware.nixosModules.lenovo-yoga-7-14ARH7-amdgpu # TODO: create custom version for Lenovo Yoga Slim 7 Pro 14ACH5 82MS

        ./configuration.nix
        ./hardware.nix
        ./power-management.nix
        ./system.nix
        ./user-interface.nix

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
        ../../users/michael/meridian
      ];
    };
    # diskoConfigurations = import ./disko.nix;
  };
}
