{
  description = "NixOS configuration";

  inputs = {
    # Packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Premade modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # Hardware specific setup modules
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules"; # Alternativ to nix hardware-configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deployment & secret tools
    sops-nix.url = "github:Mic92/sops-nix";
    lollypops.url = "github:pinpox/lollypops";
    deploy-rs.url = "github:serokell/deploy-rs";

    # Theming and customization
    nix-colors.url = "github:misterio77/nix-colors"; # Theming in nix configuration

    # nix/flake utilities
    devshell.url = "github:numtide/devshell";
  };

  outputs = {self, ...} @ inputs: let
    # Add deploy-rs to inputs here
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = [inputs.devshell.overlays.default];
    };
  in rec {
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules;

    nixosConfigurations = {
      daniel = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          modules = nixosModules;
        };
        modules = [
          {nixpkgs.config.allowUnfree = true;}
          ./machines/desktops/daniel
          ./machines/shared/core
          ./machines/shared/avahi.nix
          ./secrets
        ];
      };

      pisces = let
        tmpPkgs = import inputs.nixpkgs {
          system = "aarch64-linux";
          overlays = [overlays.additions];
          nixpkgs.config = {
            allowUnfree = true;
            extra-substituters = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
              "https://cache.garnix.io"
              "https://numtide.cachix.org"
              "https://raspberry-pi-nix.cachix.org"
              "https://nix-gaming.cachix.org"
              "https://cuda-maintainers.cachix.org"
            ];
            extra-trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
              "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
              "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
              "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
              "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            ];
          };
        };
      in
        inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
            modules = nixosModules;
          };
          modules = [
            ({...}: {nixpkgs.pkgs = tmpPkgs;})
            inputs.nixos-hardware.nixosModules.raspberry-pi-3
            ./machines/servers/pisces
            ./machines/shared/core
            ./machines/shared/avahi.nix
            ./secrets
            # Add any deploy-rs specific system configurations here if needed in the future,
            # but typically none are required for basic deployment.
          ];
        };
    };

    images = {
      pisces = self.nixosConfigurations.pisces.config.system.build.sdImage;
    };

    apps."x86_64-linux".deploy = inputs.lollypops.apps."x86_64-linux".default {configFlake = self;};

    devShells."x86_64-linux".default = import ./shell.nix {inherit inputs pkgs;};

    # deploy-rs configuration
    # deploy.nodes = {
    #   daniel = {
    #     hostname = "daniel"; # Replace with the actual hostname or IP of daniel
    #     profiles.system = {
    #       user = "root"; # Or the user you use for deployment
    #       path = self.nixosConfigurations.daniel.config.system.build.toplevel;
    #       magicRollback = true; # Recommended to enable rollback on failure
    #     };
    #   };
    #   pisces = {
    #     hostname = "192.168.1.120"; # Replace with the actual hostname or IP of pisces
    #     sshUser = "root";
    #     profiles.system = {
    #       user = "root"; # Or the user you use for deployment
    #       path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pisces;
    #       magicRollback = true; # Recommended to enable rollback on failure
    #     };
    #   };
    # };
  };
}
