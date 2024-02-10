# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  # mediaServerPath = builtins.toPath "${config.users.users.michael.home}/.temp/containers";
  mediaPath = builtins.toPath "/services/media";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./bitmagnet.nix
  ];

  boot.kernelModules = ["coretemp"];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "david"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "dk";
    xkbVariant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    isNormalUser = true;
    description = "michael";
    extraGroups = ["networkmanager" "wheel" "docker" "libvirtd"];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btop
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  networking.wireless.networks = {
    "Asus RT-AX86U" = {
      psk = "3zyn2dY&Gp";
      #pskRaw="f5e51f4b158ceb87a44bc82d2ade090948de95c90d59689d3fe8c7427cb877d2";
    };
  };

  services.logind.lidSwitchExternalPower = "ignore"; #ignore also works
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
        9020
        9696
        3333
        5055
        9696
      ];
      allowedUDPPorts = [
        9020
        9696
        3333
        5055
        9696
      ];
    };
  };

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

  # containers.prowlarr = {
  #   autoStart = true;
  #   privateNetwork = false;
  #   config = {
  #     config,
  #     pkgs,
  #     lib,
  #     ...
  #   }: {
  #     services.prowlarr = {
  #       enable = true;
  #       # openFirewall = true;
  #       # port = 8020;
  #     };

  #     networking.useHostResolvConf = lib.mkForce false;

  #     services.resolved.enable = true;

  #     system.stateVersion = "23.11";
  #   };
  # };

  virtualisation.libvirtd.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Doesn't work?????
  # services.jellyseerr = {
  #   enable = false;
  #   openFirewall = true;
  #   # port = 9020;
  # };

  services.bitmagnet = {
    enable = true;
    environment = {
      POSTGRES_USER = "postgres";
      POSTGRES_PASSWORD = "postgres";
    };
  };

  virtualisation = {
    containers.enable = true;
    docker = {
      enable = false;
      enableOnBoot = true;
    };
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Remember, podman does not create folders that are not there
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      jellyseerr = {
        image = "ghcr.io/hotio/jellyseerr";
        autoStart = true;
        ports = ["5055:5055"];
        environment = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "${config.time.timeZone}";
        };
        volumes = [
          "${mediaPath}/config/jellyseerr:/config"
        ];
      };
      prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        autoStart = true;
        ports = ["9696:9696"];
        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "${config.time.timeZone}";
        };
        volumes = [
          "${mediaPath}/config/prowlarr:/config"
        ];
      };
      # bitmagnet = {
      #   image = "ghcr.io/bitmagnet-io/bitmagnet:latest";
      #   hostname = "bitmagnet";
      #   autoStart = true;
      #   # entrypoint = "bitmagnet";
      #   cmd = [
      #     "worker"
      #     "run"
      #     "--keys=http_server"
      #     "--keys=queue_server"
      #     "--keys=dht_crawler"
      #   ];
      #   environment = {
      #     POSTGRES_PASSWORD = "postgres";
      #     POSTGRES_DB = "bitmagnet";
      #     PGUSER = "postgres";
      #     REDIS_ADDR = "0.0.0.0:6379"; # needs to be in a pod together for this to work
      #     TMDB_API_KEY = "12492bfcbf6f881563487630c079ba96";
      #   };
      #   ports = ["3334:3333"];
      #   dependsOn = ["postgres" "redis"];
      # };
      postgres = {
        image = "postgres:16-alpine";
        hostname = "bitmagnet-postgres";
        autoStart = true;
        volumes = [
          "${mediaPath}/data/postgres:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "bitmagnet";
          PGUSER = "postgres";
        };
        ports = ["5432:5432"];
      };
      redis = {
        image = "redis:7-alpine";
        hostname = "bitmagnet-redis";
        autoStart = true;
        entrypoint = "redis-server";
        cmd = ["--save 60 1"];
        volumes = [
          "${mediaPath}/data/redis:/data"
        ];
        environment = {
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "bitmagnet";
          PGUSER = "postgres";
        };
        ports = ["6379:6379"];
      };
    };
  };

  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0:11434";
  };

  lollypops.deployment = {
    local-evaluation = true;
    # Where on the remote the configuration (system flake) is placed
    config-dir = "/etc/nixos";

    # SSH connection parameters
    ssh.host = "192.168.50.71";
    ssh.user = "root";
    ssh.command = "ssh";
    ssh.opts = [];

    # sudo options
    sudo.enable = false;
    sudo.command = "sudo";
    sudo.opts = [];
  };
}
