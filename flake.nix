{
  description = "NixOS configuration";

  inputs = {
    # Package repos
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR"; # Nix User Repository
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions"; # All vscode extensions

    # Premade modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # Hardware specific setup modules
    srvos.url = "github:nix-community/srvos"; # Server specific modules

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deploment & secret tools
    lollypops.url = "github:pinpox/lollypops";
    agenix.url = "github:ryantm/agenix";

    # Individual program packages
    hyprlock.url = "github:hyprwm/hyprlock";
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";

    # Theming and customization
    nix-colors.url = "github:misterio77/nix-colors"; # Theming in nix configuration
    betterfox = {
      url = "github:yokoffing/Betterfox"; # Firefox settings    nix-inspect.url = "github:bluskript/nix-inspect";
      flake = false;
    };
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    # nix/flake utilities
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = {
    self,
    utils,
    nixpkgs,
    home-manager,
    nur,
    nixos-hardware,
    lollypops,
    agenix,
    srvos,
    ...
  } @ inputs: let
    # inherit (self) outputs;
    name = "Michael Andreas Graversen";
    email = "home@michael-graversen.dk";
  in
    utils.lib.mkFlake rec {
      inherit self inputs;

      supportedSystems = ["x86_64-linux" "aarch64-linux"];

      channelsConfig = {
        allowUnfree = true;
        allowBroken = false;
        permittedInsecurePackages = [];
      };

      sharedOverlays = [
        nur.overlay
        self.overlay.additions
        self.overlay.modifications
      ];

      # Custom packages and modifications, exported as overlays
      overlay = import ./overlays {inherit inputs;};
      nixosModules = import ./modules;

      hostDefaults = {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/core
          lollypops.nixosModules.lollypops
          agenix.nixosModules.default
        ];
      };

      hosts = {
        jason = {
          system = "x86_64-linux";
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
              home-manager.extraSpecialArgs = {inherit inputs ;};
            }
          ];
        };

        daniel = {
          system = "x86_64-linux";
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
              home-manager.extraSpecialArgs = {inherit inputs ;};
            }
          ];
        };

        david = {
          system = "x86_64-linux";
          modules = [
            ./hosts/david
            nixosModules.bitmagnet
            nixosModules.recyclarr
            nixosModules.qbittorrent
            # srvos.nixosModules.server
            # srvos.nixosModules.common
            srvos.nixosModules.mixins-terminfo
          ];
        };

        envpi = {
          system = "aarch64-linux";
          modules = [
            ./hosts/envpi
          ];
        };

        nixpi = {
          system = "aarch64-linux";
          modules = [
            ./hosts/nixpi
          ];
        };
      };

      # packages = nixpkgs.lib.genAttrs supportedSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      outputsBuilder = channels: {
        apps = {
          default = lollypops.apps.${nixpkgs.stdenv.hostPlatform.system}.default {configFlake = self;};
        };

        # output packages for all supported systems
        # packages = channels.nixpkgs.lib.genAttrs supportedSystems (system: import ./pkgs channels.nixpkgs.legacyPackages.${system});
        packages = channels.nixpkgs.lib.genAttrs supportedSystems overlay.additions.qbitmanage;

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
            nixos-generators
          ];
        };
      };
    };
}
