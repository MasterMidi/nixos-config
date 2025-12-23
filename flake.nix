{
  description = "A dendritic NixOS configuration for all my machines.";

  nixConfig = {
    allowUnfree = true;
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
      "https://install.determinate.systems" # determinate nix
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=" # determinate nix
    ];
  };

  inputs = {
    # packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/=3.11.2"; # Deploy-rs is still broken for me with version nix version 2.32. This is latest determinate nix with version 2.31

    # All vscode extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    # Core Flake Libraries
    flake-parts.url = "github:hercules-ci/flake-parts";

    # nix/flake utilities
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # Hardware specific setup modules
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules"; # Alternativ to nix hardware-configuration
    disko = {
      # Declarative disk configuration
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming.url = "github:fufexan/nix-gaming";

    # deployment & secret tools
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kubenix = {
      url = "github:hall/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming and customization
    nix-colors.url = "github:misterio77/nix-colors"; # Theming in nix configuration
    betterfox = {
      url = "github:yokoffing/Betterfox"; # Firefox settings
      flake = false;
    };
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.disko.flakeModules.default

        ./shell.nix

        ./modules/nixos
        ./modules/flakes

        ./hosts/meridian # Laptop
        ./hosts/andromeda # Nas / Server
        ./hosts/aether # Hetzner vps
        ./hosts/zenith # Workstation
        ./hosts/callisto # Raspi 5
        ./hosts/hyperion # wsl work laptop
        ./hosts/voyager
        # ./hosts/eris # Raspi 3
        # ./hosts/polaris # Old asus laptop
        # ./hosts/altair # spare server
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { system, ... }:
        {
          packages.k8s =
            (inputs.kubenix.evalModules.${system} {
              module =
                { kubenix, ... }:
                {
                  imports = [ kubenix.modules.k8s ];
                  kubernetes.resources.pods.example.spec.containers.nginx.image = "nginx";

                  kubernetes.resources = {
                    deployments.sonarr = {
                      apiVersion = "apps/v1";
                      kind = "Deployment";
                      metadata = {
                        name = "sonarr";
                        labels = {
                          app = "sonarr";
                        };
                      };
                      spec = {
                        replicas = 1;
                        selector = {
                          matchLabels = {
                            app = "sonarr";
                          };
                        };
                        template = {
                          metadata = {
                            labels = {
                              app = "sonarr";
                            };
                          };
                          spec = {
                            containers = [
                              {
                                name = "sonarr";
                                image = "ghcr.io/hotio/sonarr:latest";
                                ports = [
                                  {
                                    containerPort = 8989;
                                    name = "http";
                                  }
                                ];
                                env = [
                                  {
                                    name = "PUID";
                                    value = "1000";
                                  }
                                  {
                                    name = "PGID";
                                    value = "100";
                                  }
                                  {
                                    name = "TZ";
                                    value = "Europe/Copenhagen";
                                  }
                                ];
                                volumeMounts = [
                                  {
                                    name = "sonarr-config";
                                    mountPath = "/config";
                                  }
                                  {
                                    name = "sonarr-media";
                                    mountPath = "/data";
                                  }
                                ];
                              }
                            ];
                            volumes = [
                              {
                                name = "sonarr-config";
                                hostPath = {
                                  path = "/home/michael/.testing/k3s/sonarr-config";
                                  type = "DirectoryOrCreate";
                                };
                              }
                              {
                                name = "sonarr-media";
                                hostPath = {
                                  path = "/home/michael/.testing/k3s/sonarr-media";
                                  type = "Directory";
                                };
                              }
                            ];
                          };
                        };
                      };
                    };
                    persistentVolumes = {
                      apiVersion = "v1";
                      kind = "PersistentVolume";
                      metadata = {
                        name = "jellyfin-videos";
                      };
                      spec = {
                        capacity = {
                          storage = "400Gi";

                        };
                        accessModes = [ "ReadWriteOnce" ];
                        nfs = {
                          path = "/volume1/server/k3s/media";
                          server = "storage.merox.cloud";

                        };
                        persistentVolumeReclaimPolicy = "Retain";
                        mountOptions = [
                          "hard"
                          "nfsvers=3"

                        ];
                        storageClassName = "";
                      };
                    };

                    persistentVolumeClaims = {
                      apiVersion = "v1";
                      kind = "PersistentVolumeClaim";
                      metadata = {
                        name = "jellyfin-videos";
                        namespace = "media";
                      };
                      spec = {
                        accessModes = [
                          "ReadWriteOnce"

                        ];
                        resources.requests.storage = "400Gi";
                        volumeName = "jellyfin-videos";
                        storageClassName = "";

                      };

                    };
                  };
                };
            }).config.kubernetes.result;
        };

      flake.checks = builtins.mapAttrs (
        system: deployLib: deployLib.deployChecks self.deploy
      ) inputs.deploy-rs.lib;
    };
}
