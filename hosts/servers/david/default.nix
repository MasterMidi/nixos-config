{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    # ./monitoring
    ./secrets
    ./hardware-configuration.nix
    # ./nginx.nix
  ];

  boot.kernelModules = ["coretemp"];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "david"; # Define your hostname.

  # Configure keymap in X11
  services.xserver = {
    layout = "dk";
    xkbVariant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = lib.mkForce true;
  users.users.michael = {
    isNormalUser = true;
    description = "michael";
    extraGroups = ["networkmanager" "wheel" "docker" "podman"];
    packages = with pkgs; [jellyseerr];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kitty.terminfo
    nfs-utils
    btop
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  system.stateVersion = "23.05"; # Did you read the comment?

  # Enable networking
  networking.networkmanager.enable = true;

  services.logind.lidSwitchExternalPower = "ignore";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  services.fstrim.enable = true;

  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = ["ve-+"];
  #   externalInterface = "ens3";
  #   # Lazy IPv6 connectivity for the container
  #   enableIPv6 = true;
  # };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        5353 # mDNS
        9020
        9696
        3333
        5055
        9696

        80
        443
      ];
      allowedUDPPorts = [
        5353 # mDNS
        9020
        9696
        3333
        5055
        9696
      ];
    };
  };

  # virtualisation.docker = {
  #   enable = true;
  #   enableOnBoot = true;
  #   rootless = {
  #     enable = true;
  #     setSocketVariable = true;
  #   };
  # };

  # virtualisation.oci-containers = {
  #   backend = "docker";
  #   containers = {
  #     kavita = {
  #       image = "jvmilazz0/kavita:latest";
  #       # user = "1000:100";
  #       autoStart = true;
  #       ports = ["5000:5000"];
  #       environment = {
  #         TZ = config.time.timeZone;
  #       };
  #       volumes = [
  #         "/var/lib/kavita/config:/kavita/config"
  #         "/var/lib/kavita/data:/data"
  #       ];
  #     };
  #   };
  # };

  # containers.jellyseerr = {
  #   autoStart = true;
  #   privateNetwork = false;
  #   config = {
  #     config,
  #     pkgs,
  #     lib,
  #     ...
  #   }: {
  #     services.jellyseerr = {
  #       enable = true;
  #       # openFirewall = true;
  #       port = 9020;
  #     };

  #     networking.useHostResolvConf = lib.mkForce false;

  #     services.resolved.enable = true;

  #     system.stateVersion = "23.11";
  #   };
  # };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.prowlarr = {
    enable = false;
    openFirewall = true;
    # port = 8020;
  };

  # Runtime
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
      # network_interface = "podman0";
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Firewall
  networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];

  # Containers
  virtualisation.oci-containers.compose.mediaserver = {
    enable = true;
    networks.default = {};
    containers = {
      bitmagnet = {
        image = "ghcr.io/bitmagnet-io/bitmagnet:v0.10.0-beta.5";
        networking = {
          networks = ["default"];
          aliases = ["bitmagnet"];
          ports = {
            webui = {
              host = 3333;
              internal = 3333;
            };
            crawler1 = {
              host = 3334;
              internal = 3334;
              protocol = "tcp";
            };
            crawler2 = {
              host = 3334;
              internal = 3334;
              protocol = "udp";
            };
          };
        };
        environment = {
          POSTGRES_HOST = "bitmagnet-postgres";
          POSTGRES_NAME = "bitmagnet";
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          # TMDB_API_KEY  = config.sops.secrets.TMDB_KEY.path;
        };
        commands = [
          "worker"
          "run"
          "--keys=http_server"
          "--keys=queue_server"
          # disable the next line to run without DHT crawler
          "--keys=dht_crawler"
        ];
        dependsOn = ["bitmagnet-postgres"];
      };
      bitmagnet-postgres = {
        image = "postgres:16-alpine";
        networking = {
          networks = ["default"];
          aliases = ["bitmagnet-postgres"];
          ports = {
            main = {
              host = 5432;
              internal = 5432;
            };
          };
        };
        volumes = [
          "/root/data/postgres:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "bitmagnet";
          PGUSER = "postgres";
        };
        extraOptions = ["--shm-size=1g"];
      };
    };
  };

  # bitmagnet = {
  #         image = "ghcr.io/bitmagnet-io/bitmagnet:latest";
  #         hostname = "bitmagnet";
  #         autoStart = true;
  #         environment =
  #           cfg.environment
  #           // {
  #             POSTGRES_HOST = cfg.postgresHost;
  #             POSTGRES_NAME = cfg.postgresName;
  #             POSTGRES_USER = cfg.postgresUser;
  #             POSTGRES_PASSWORD = cfg.postgresPassword;
  #           };
  #         ports = [
  #           "3333:3333"
  #           "3334:3334/tcp"
  #           "3334:3334/udp"
  #         ];
  #         cmd = [
  #           "worker"
  #           "run"
  #           "--keys=http_server"
  #           "--keys=queue_server"
  #           # disable the next line to run without DHT crawler
  #           "--keys=dht_crawler"
  #         ];
  #         dependsOn = ["bitmagnet-postgres"];
  #         extraOptions = ["--network=host"];
  #       };

  #       bitmagnet-postgres = {
  #         image = "postgres:16-alpine";
  #         hostname = "bitmagnet-postgres";
  #         autoStart = true;
  #         volumes = [
  #           "/root/data/postgres:/var/lib/postgresql/data"
  #         ];
  #         environment = {
  #           POSTGRES_PASSWORD = cfg.postgresPassword;
  #           POSTGRES_DB = cfg.postgresName;
  #           PGUSER = cfg.postgresUser;
  #         };
  #         extraOptions = ["--shm-size=1g"];
  #         ports = ["5432:5432"];
  #       };

  #       redis = {
  #         image = "redis:7-alpine";
  #         hostname = "bitmagnet-redis";
  #         autoStart = true;
  #         entrypoint = "redis-server";
  #         cmd = ["--save 60 1"];
  #         volumes = [
  #           "/root/data/redis:/data"
  #         ];
  #         environment = {
  #           POSTGRES_PASSWORD = "postgres";
  #           POSTGRES_DB = "bitmagnet";
  #           PGUSER = "postgres";
  #         };
  #         ports = ["6379:6379"];
  #       };

  services.nginx = {
    # virtualHosts."jellyseerr.michael-graversen.dk" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://localhost:5055"; # Proxy to Jellyseerr
    #     proxyWebsockets = true; # needed if you need to use WebSocket
    #     extraConfig = ''
    #     '';
    #   };
    # };
    # virtualHosts."jellyfin.michael-graversen.dk" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://192.168.50.2:9010"; # Proxy to Jellyseerr
    #     proxyWebsockets = true; # needed if you need to use WebSocket
    #     extraConfig = ''
    #     '';
    #   };
    # };
  };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "home@michael-graversen.dk";
  # };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  services.ollama = {
    enable = false;
    port = "11434";
  };

  lollypops.deployment = {
    local-evaluation = true;
    # Where on the remote the configuration (system flake) is placed
    # config-dir = "/etc/nixos/";

    # SSH connection parameters
    ssh.host = "${config.networking.hostName}.local";
    ssh.user = "root";
    ssh.command = "ssh";
    ssh.opts = [];

    # sudo options
    sudo.enable = false;
    sudo.command = "sudo";
    sudo.opts = [];
  };

  ### TESTING AREA ###

  # fileSystems."/mnt/storage" = {
  #   device = "192.168.50.2:/storage";
  #   fsType = "nfs";
  #   options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=90"];
  # };

  # users.groups.media = {gid = 500;};

  # users.users = {
  #   media = {
  #     group = "media";
  #     uid = 500;
  #     isSystemUser = true;
  #     createHome = true;
  #     home = "/var/lib/media";
  #   };
  # };

  # services.sonarr = {
  #   enable = true;
  #   openFirewall = true;
  #   # dataDir = "/var/lib/media/.config/sonarr";
  #   # user = "media";
  #   group = "media";
  # };

  # services.radarr = {
  #   enable = true;
  #   openFirewall = true;
  #   # dataDir = "/var/lib/media/.config/radarr";
  #   # user = "media";
  #   group = "media";
  # };

  # services.bazarr = {
  #   enable = true;
  #   openFirewall = true;
  #   # user = "media";
  #   group = "media";
  # };

  # services.qbittorrent = {
  #   enable = true;
  #   openFirewall = true;
  #   # dataDir = "/var/lib/media/qBittorrent";
  #   # user = "media";
  #   group = "media";
  #   webUIAddress.port = 8080;
  # };
}
