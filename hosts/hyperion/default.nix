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

        ./configuration.nix

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
        ../../users/michael/graphical
      ];
    };
  };
}
