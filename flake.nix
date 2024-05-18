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
    caligula.url = "github:ifd3f/caligula";

    # Theming and customization
    nix-colors.url = "github:misterio77/nix-colors"; # Theming in nix configuration
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    betterfox = {
      url = "github:yokoffing/Betterfox"; # Firefox settings
      flake = false;
    };
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    thunderbird-gnome-theme = {
      url = "github:rafaelmardojai/thunderbird-gnome-theme";
      flake = false;
    };

    # nix/flake utilities
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = {
    self,
    utils,
    ...
  } @ inputs: let
    # inherit (self) outputs;
    name = "Michael Andreas Graversen";
    email = "home@michael-graversen.dk";
  in
    utils.lib.mkFlake rec {
      inherit self inputs;

      supportedSystems = ["x86_64-linux" "aarch64-linux"];

      nix = {
        generateNixPathFromInputs = true;
        generateRegistryFromInputs = true;
        linkInputs = true;
      };

      channelsConfig = {
        allowUnfree = true;
        allowBroken = false;
        permittedInsecurePackages = [];
      };

      sharedOverlays = [
        inputs.nur.overlay
        overlay.additions
        self.overlay.modifications
      ];

      # Custom packages and modifications, exported as overlays
      overlay = import ./overlays {inherit inputs;};
      nixosModules = import ./modules;

      hostDefaults = {
        specialArgs = {inherit inputs;};
        modules = with inputs; [
          ./system/core
          ./scripts
          lollypops.nixosModules.lollypops
          agenix.nixosModules.default
          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.extraSpecialArgs = {inherit inputs;};
          #   home-manager.sharedModules = [
          #     ./home/core
          #   ];
          # }
        ];
      };

      hosts = {
        jason = {
          system = "x86_64-linux";
          modules = [
            ./hosts/jason
            nixosModules.refind
            nixosModules.vfio
            # outputs.nixosModules.qbitmanage

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael = import ./home/michael;
              home-manager.sharedModules = [
                ./home/core
              ];
            }
          ];
        };

        daniel = {
          system = "x86_64-linux";
          modules = [
            ./hosts/daniel
            inputs.nixos-hardware.nixosModules.lenovo-ideapad-slim-5
            inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.michael = import ./home/michael;

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
              home-manager.extraSpecialArgs = {inherit inputs;};
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
            inputs.srvos.nixosModules.mixins-terminfo
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael = import ./home/michael.david;
              home-manager.sharedModules = [
                ./home/core
              ];
            }
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

      outputsBuilder = channels: {
        apps = {
          default = inputs.lollypops.apps.${channels.nixpkgs.stdenv.hostPlatform.system}.default {configFlake = self;};
        };

        formatter = channels.nixpkgs.alejandra;

        # output packages for all supported systems
        packages = channels.nixpkgs.lib.genAttrs supportedSystems (system: import ./pkgs channels.nixpkgs.legacyPackages.${system});

        # dev shell with tools for working with nix configuration
        devShell = import ./shell.nix {pkgs = channels.nixpkgs;};
      };
    };
}
