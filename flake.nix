{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR"; # Nix User Repository

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lollypops.url = "github:pinpox/lollypops";
    agenix.url = "github:ryantm/agenix";

    # hyprland.url = "github:hyprwm/Hyprland";
    hyprlock.url = "github:hyprwm/hyprlock";
    ags.url = "github:Aylur/ags";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-colors.url = "github:misterio77/nix-colors"; # better nix theming?
    # stylix.url = "github:danth/stylix";

    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = inputs @ {
    self,
    utils,
    nixpkgs,
    home-manager,
    nur,
    nixos-hardware,
    lollypops,
    agenix,
    nix-colors,
    ...
  }: let
    # inherit (self) outputs;
  in
    utils.lib.mkFlake rec {
      inherit self inputs;

      supportedSystems = ["x86_64-linux" "aarch64-linux"];

      channelsConfig = {
        allowUnfree = true;
        allowBroken = false;

        permittedInsecurePackages = [
          # "electron-25.9.0" # TODO remove when culprit found
          # "electron-19.1.9" # TODO remove when culprit found
          # "nix-2.16.2"
        ];
      };

      sharedOverlays = [
        nur.overlay
        self.overlay.additions
        self.overlay.modifications
        self.overlay.vscode-extensions
      ];

      # Custom packages and modifications, exported as overlays
      overlay = import ./overlays {inherit inputs;};
      nixosModules = import ./modules;

      hostDefaults = {
        extraArgs = {inherit nix-colors;};
        modules = [
          ./hosts/core
          lollypops.nixosModules.lollypops
          agenix.nixosModules.default
        ];
      };

      hosts = {
        jason = {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;}; # this is the important part
          modules = [
            ./hosts/jason
            ./scripts
            nixosModules.refind
            # outputs.nixosModules.qbitmanage

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.michael = import ./home;

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
              home-manager.extraSpecialArgs = {inherit inputs nix-colors;};
            }
          ];
        };

        daniel = {
          system = "x86_64-linux";

          specialArgs = {inherit inputs;}; # this is the important part
          modules = [
            ./hosts/daniel
            ./scripts
            nixos-hardware.nixosModules.lenovo-ideapad-slim-5
            nixos-hardware.nixosModules.common-cpu-amd-pstate

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.michael = import ./home;

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
              home-manager.extraSpecialArgs = {inherit inputs nix-colors;};
            }
          ];
        };

        david = {
          system = "x86_64-linux";

          specialArgs = {inherit inputs;}; # this is the important part
          modules = [
            ./hosts/david
            nixosModules.bitmagnet
            nixosModules.recyclarr
            nixosModules.jellyseerr
          ];
        };

        envpi = {
          system = "aarch64-linux";

          specialArgs = {inherit inputs;}; # this is the important part
          modules = [
            ./hosts/envpi
          ];
        };

        nixpi = {
          system = "aarch64-linux";

          specialArgs = {inherit inputs;}; # this is the important part
          modules = [
            ./hosts/nixpi
          ];
        };
      };

      packages = nixpkgs.lib.genAttrs supportedSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      outputsBuilder = channels: {
        apps = {
          default = lollypops.apps."x86_64-linux".default {configFlake = self;};
        };

        # output packages for all supported systems
        # packages = channels.nixpkgs.lib.genAttrs supportedSystems (system: import ./pkgs channels.nixpkgs.legacyPackages.${system});
        # packages = {
        #   inherit channels;
        #   refind-minimal = import ./pkgs/refind-minimal nixpkgs.legacyPackages."x86_64-linux";
        # };

        # dev shell with tools for working with nix configuration
        devShell = channels.nixpkgs.mkShell {
          name = "nixos-config";
          buildInputs = with channels.nixpkgs; [
            nerdfix
            nurl
            nix-prefetch
            nix-tree
            nix-output-monitor
            nix-index
            nix-melt # view flake.lock files
            nix-init # quick start to packaging projects
            statix # find anti-patterns in nix code
            nix-du # disk usage of nix store
          ];
        };
      };
    };
}
