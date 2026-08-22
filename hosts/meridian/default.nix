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

        self.nixosModules.hyprland
        self.nixosModules.hyprlock
        self.nixosModules.tailscale
        # self.nixosModules.nix-builder
        self.nixosModules.laptop-power-management
        self.nixosModules.lenovo-yoga-7-14ARH7-power-management
        self.nixosModules.zed

        ./configuration.nix
        ./development.nix
        self.nixosModules.facter
        ./hardware.nix
        ./system.nix
        ./user-interface.nix

        # profiles
        ../../profiles/common.nix
        ../../profiles/bare-metal.nix
        ../../profiles/mdns.nix
        self.nixosModules.nix-interactive-machine
        self.nixosModules.sops
        self.nixosModules.bluetooth
        self.nixosModules.sound
        self.nixosModules.sound-wh-1000xm3
        self.nixosModules.boot-splash-screen

        # Users
        ../../users/root/common.nix
        ../../users/michael/meridian
        {
          home-manager.users.michael.imports = [
            self.homeModules.k8s-cluster-administration
            self.homeModules.hyprland
            self.homeModules.hyprlock-meridian
            self.homeModules.jujutsu
            self.homeModules.opencode
            self.homeModules.zed
          ];
        }
      ];
    };
    # diskoConfigurations = import ./disko.nix;
  };
}
