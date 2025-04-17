# TODO: make git ssh agent ask only once (like magnus setup)
# TODO: add git ssh keys to sops so all devices can use the same keys
# TODO: Automate adding new devices to sops
{
  description = "NixOS configuration";

  inputs = {
    # Package repos
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nur.url = "github:nix-community/NUR"; # Nix User Repository
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions"; # All vscode extensions

    # Premade modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # Hardware specific setup modules
    srvos.url = "github:nix-community/srvos"; # Server specific modules
    raspberry-pi-nix.url = "github:cmyk/raspberry-pi-nix"; # easily create pi images
    nix-gaming.url = "github:fufexan/nix-gaming"; # gaming related
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deployment & secret tools
    lollypops.url = "github:pinpox/lollypops";
    deploy-rs.url = "github:serokell/deploy-rs";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-generators.url = "github:nix-community/nixos-generators";

    # Individual program packages
    ags.url = "github:Aylur/ags";
    caligula.url = "github:ifd3f/caligula";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    solaar = {
      url = "github:Svenum/Solaar-Flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming and customization
    nix-colors.url = "github:misterio77/nix-colors"; # Theming in nix configuration
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
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
    vuetorrent = {
      url = "github:VueTorrent/VueTorrent/latest-release";
      flake = false;
    };

    # nix/flake utilities
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    devshell.url = "github:numtide/devshell";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    utils,
    ...
  } @ inputs:
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
        allowBroken = true;
        permittedInsecurePackages = [];
      };

      sharedOverlays = [
        inputs.nur.overlays.default
        inputs.devshell.overlays.default
        overlays.additions
        overlays.modifications
        overlays.packages
        inputs.raspberry-pi-nix.overlays.core
      ];

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays {inherit inputs;};
      nixosModules = import ./modules; # Maybe overlay the modules instead of importing them individually

      hostDefaults = {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/shared/core
          ./scripts
          inputs.lollypops.nixosModules.lollypops
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs;};
            home-manager.users.root.imports = [./home/shared/users/root];
            home-manager.sharedModules = [
              ./home/shared/core
              inputs.nix-colors.homeManagerModules.default # import color themes for all users
              inputs.sops-nix.homeManagerModules.sops # add sops to all users
            ];
          }
        ];
      };

      hosts = {
        jason = {
          system = "x86_64-linux";
          modules = [
            ./hosts/desktop/jason
            ./hosts/shared/networking
            nixosModules.configs.refind
            nixosModules.configs.vfio
            nixosModules.configs.compose
            nixosModules.services.metrics
            nixosModules.services.qbittorrent
            nixosModules.services.qbitmanage

            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael.imports = [
                ./hosts/desktop/jason/home
                ./home/desktop
              ];
            }
          ];
        };

        daniel = {
          system = "x86_64-linux";
          modules = [
            ./hosts/desktop/daniel
            ./hosts/shared/networking
            inputs.nixos-hardware.nixosModules.lenovo-ideapad-slim-5
            inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
            nixosModules.services.otbr

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael.imports = [
                ./hosts/desktop/daniel/home
                ./home/desktop
              ];
            }
          ];
        };

        david = {
          system = "x86_64-linux";
          modules = [
            ./hosts/servers/david
            ./hosts/servers/shared/core
            ./hosts/shared/networking
            nixosModules.configs.compose
            nixosModules.services.qbittorrent
            # srvos.nixosModules.server
            # srvos.nixosModules.common
            inputs.srvos.nixosModules.mixins-terminfo
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael.imports = [
                ./hosts/servers/david/home
              ];
            }
          ];
        };

        andromeda = {
          system = "x86_64-linux";
          modules = [
            ./hosts/servers/andromeda
            ./hosts/servers/shared/core
            ./hosts/shared/networking
            nixosModules.configs.compose
            nixosModules.services.qbittorrent
            # srvos.nixosModules.server
            # srvos.nixosModules.common
            inputs.jovian.nixosModules.default
            inputs.srvos.nixosModules.mixins-terminfo
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael.imports = [
                ./hosts/servers/andromeda/home
              ];
            }
          ];
        };

        nova = {
          system = "x86_64-linux";
          modules = [
            ./hosts/servers/nova
            ./hosts/servers/shared/core
            nixosModules.configs.compose
            inputs.srvos.nixosModules.mixins-terminfo
            inputs.disko.nixosModules.disko
          ];
        };

        # TODO: turn into bluetooth speaker device
        # TODO: make this a log aggregator for all systems
        # TODO: Make this a dns-sinkhole
        # envpi = {
        #   system = "aarch64-linux";
        #   modules = [
        #     ./hosts/servers/envpi
        #     ./hosts/servers/shared/core
        #     inputs.nixos-hardware.nixosModules.raspberry-pi-3
        #   ];
        # };

        pisces = {
          system = "aarch64-linux";
          modules = [
            "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./hosts/servers/pisces
            ./hosts/servers/shared/core
            ./hosts/shared/networking
            inputs.nixos-facter-modules.nixosModules.facter
            inputs.nixos-hardware.nixosModules.raspberry-pi-3
            nixosModules.services.otbr
          ];
        };

        polaris = {
          system = "aarch64-linux";
          modules = [
            ./hosts/servers/polaris
            ./hosts/servers/shared/core
            ./hosts/shared/networking
            inputs.raspberry-pi-nix.nixosModules.raspberry-pi
            inputs.raspberry-pi-nix.nixosModules.sd-image
            inputs.nixos-hardware.nixosModules.raspberry-pi-5
            # inputs.home-manager.nixosModules.home-manager
            # {
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;
            #   home-manager.extraSpecialArgs = {inherit inputs;};
            #   home-manager.users.michael.imports = [
            #     ./hosts/servers/polaris/home
            #     ./home/shared/core
            #   ];
            # }
          ];
        };
      };

      outputsBuilder = channels: {
        apps = {
          default = inputs.lollypops.apps.${channels.nixpkgs.stdenv.hostPlatform.system}.default {configFlake = self;};
        };

        formatter = channels.nixpkgs.alejandra;

        # output packages for all supported systems
        # packages = channels.nixpkgs.lib.genAttrs supportedSystems (system: import ./pkgs channels.nixpkgs.legacyPackages.${system});
        packages = {inherit (channels.nixpkgs) qbitmanage;};

        # dev shell with tools for working with nix configuration
        devShells.default = import ./shell.nix {
          inherit inputs;
          pkgs = channels.nixpkgs;
        };
      };

      images = {
        polaris = self.nixosConfigurations.polaris.config.system.build.sdImage;
        envpi = self.nixosConfigurations.envpi.config.system.build.sdImage;
        pisces = self.nixosConfigurations.pisces.config.system.build.sdImage;
      };

      deploy.nodes.andromeda = {
        hostname = "andromeda";
        fastConnection = true;
        interactiveSudo = true;
        profiles = {
          system = {
            sshUser = "root";
            path =
              inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.andromeda;
            user = "root";
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
    };
}
