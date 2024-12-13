{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./monitoring
    ./hardware-configuration.nix
    ./recyclarr
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
    extraGroups = ["networkmanager" "wheel" "docker"];
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

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      kavita = {
        image = "jvmilazz0/kavita:latest";
        # user = "1000:100";
        autoStart = true;
        ports = ["5000:5000"];
        environment = {
          TZ = config.time.timeZone;
        };
        volumes = [
          "/var/lib/kavita/config:/kavita/config"
          "/var/lib/kavita/data:/data"
        ];
      };
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

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    # port = 8020;
  };

  services.bitmagnet = {
    enable = true;
    # package = let
    #   version = "0.7.5";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "bitmagnet-io";
    #     repo = "bitmagnet";
    #     rev = "v${version}";
    #     sha256 = "sha256-hyF0SwhMXpM7imjVmxFaX+Z6h9tiZvZszVTEdhUGvFY=";
    #   };
    # in (pkgs.bitmagnet.override rec {
    #   buildGoModule = args:
    #     pkgs.buildGo122Module (args
    #       // {
    #         inherit src version;
    #         vendorHash = "sha256-y9RfaAx9AQS117J3+p/Yy8Mn5In1jmZmW4IxKjeV8T8=";
    #       });
    # });
    environment = {
      # TMDB_API_KEY = builtins.readFile config.sops.secrets.TMDB_KEY.path;
    };
  };

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
