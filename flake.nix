{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Premade modules
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deployment & secret tools
    sops-nix.url = "github:Mic92/sops-nix";

    # Theming and customization
    nix-colors.url = "github:misterio77/nix-colors"; # Theming in nix configuration

    # nix/flake utilities
    devshell.url = "github:numtide/devshell";
  };

  outputs = {self, ...} @ inputs: let
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = [inputs.devshell.overlays.default];
    };
  in {
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules;

    nixosConfigurations = {
      daniel = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          inputs.home-manager.nixosModules.home-manager
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.sops-nix.nixosModules.sops
          # nixosModules.options
          ./machines/desktops/daniel
          ./machines/shared/core
          ./secrets
        ];
      };
    };

    devShells."x86_64-linux".default = import ./shell.nix {inherit inputs pkgs;};
  };
}
