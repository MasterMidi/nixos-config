# TODO: make git ssh agent ask only once (like magnus setup)
# TODO: add git ssh keys to sops so all devices can use the same keys
# TODO: Automate adding new devices to sops
{
  description = "NixOS configuration";

  nixConfig = {
    extra-substituters = ["https://raspberry-pi-nix.cachix.org"];
    extra-trusted-public-keys = [
      "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
    ];
  };

  inputs = {
    # Package repos
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR"; # Nix User Repository
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions"; # All vscode extensions

    # Premade modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # Hardware specific setup modules
    srvos.url = "github:nix-community/srvos"; # Server specific modules
    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix"; # easily create pi images

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
    ccase = {
      url = "github:rutrum/ccase";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
        inputs.nur.overlay
        inputs.devshell.overlays.default
        overlays.additions
        overlays.modifications
      ];

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays {inherit inputs;};
      nixosModules = import ./modules; # Maybe overlay the modules instead of importing them individually

      hostDefaults = {
        specialArgs = {inherit inputs;};
        modules = with inputs; [
          ./system/core
          ./scripts
          lollypops.nixosModules.lollypops
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs;};
            home-manager.users.root = import ./home/root;
            home-manager.sharedModules = [
              ./home/core
            ];
          }
        ];
      };

      hosts = {
        jason = {
          system = "x86_64-linux";
          modules = [
            ./hosts/jason
            inputs.disko.nixosModules.disko
            nixosModules.configs.refind
            nixosModules.configs.vfio
            nixosModules.services.metrics
            nixosModules.services.qbittorrent
            nixosModules.services.recyclarr
            nixosModules.services.qbitmanage

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael = import ./home/michael;
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
              home-manager.backupFileExtension = "backup";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael = import ./home/michael;
            }
          ];
        };

        david = {
          system = "x86_64-linux";
          modules = [
            ./hosts/david
            nixosModules.services.bitmagnet
            nixosModules.services.recyclarr
            nixosModules.services.qbittorrent
            # srvos.nixosModules.server
            # srvos.nixosModules.common
            inputs.srvos.nixosModules.mixins-terminfo
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael = import ./home/michael.david;
            }
          ];
        };

        andromeda = {
          system = "x86_64-linux";
          modules = [
            ./hosts/andromeda
            nixosModules.services.qbittorrent
            # srvos.nixosModules.server
            # srvos.nixosModules.common
            inputs.srvos.nixosModules.mixins-terminfo
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.michael = import ./home/michael.david;
            }
          ];
        };

        # TODO: turn into bluetooth speaker device
        envpi = {
          system = "aarch64-linux";
          modules = [
            ./hosts/envpi
            inputs.nixos-hardware.nixosModules.raspberry-pi-3
          ];
        };

        # TODO: make this a log aggregator for all systems
        # TODO: Make this a dns-sinkhole
        nixpi = {
          system = "aarch64-linux";
          modules = [
            ./hosts/nixpi
            inputs.nixos-hardware.nixosModules.raspberry-pi-3
          ];
        };

        polaris = {
          system = "aarch64-linux";
          modules = [
            ./hosts/polaris
            ./system/core
            inputs.raspberry-pi-nix.nixosModules.raspberry-pi
            # inputs.nixos-hardware.nixosModules.raspberry-pi-5
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

    
      nixosConfigurations.rpi5 = let
      inherit (inputs.nixpkgs-stable.lib) nixosSystem;
      basic-config = { pkgs, lib, ... }: {
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };
        time.timeZone = "America/New_York";
        users.users.root.initialPassword = "root";
        networking = {
          hostName = "polaris";
          useDHCP = false;
          interfaces = { wlan0.useDHCP = true; };
          wireless = {
            enable = true;
            networks."Asus RT-AX86U".psk = "3zyn2dY&Gp";
            networks."McDonald's McWifi".psk = "lady121205";
          };
        };
        environment.systemPackages = with pkgs; [ bluez bluez-tools ];
        hardware = {
          bluetooth.enable = true;
          raspberry-pi = {
            config = {
              all = {
                base-dt-params = {
                  # enable autoprobing of bluetooth driver
                  # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                  krnbt = {
                    enable = true;
                    value = "on";
                  };
                };
              };
            };
          };
        };
      };

    in 
      nixosSystem {
        system = "aarch64-linux";
        modules = [
          # ./hosts/polaris
          # # inputs.nixos-hardware.nixosModules.raspberry-pi-5
          # # ./system/core
          # inputs.lollypops.nixosModules.lollypops
          basic-config
          inputs.raspberry-pi-nix.nixosModules.raspberry-pi
          # ({...}:{
          #   nixpkgs.config.allowUnsupportedSystem = true;
          #   # nixpkgs.hostPlatform.system = "aarch64-linux";
          #   # nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 otherwise changes this.
          #   sdImage.compressImage = true;
          # })
        ];
      };

      images = {
        rpi5 = nixosConfigurations.rpi5.config.system.build.sdImage;
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
