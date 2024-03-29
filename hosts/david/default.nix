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
    ./recyclarr.nix
    ../core
  ];

  boot.kernelModules = ["coretemp"];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "david"; # Define your hostname.

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

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

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

  virtualisation.libvirtd.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Doesn't work?????
  services.jellyseerr = {
    enable = false;
  };

  services.jellyseerr2 = {
    enable = false;
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    # port = 8020;
  };

  services.bitmagnet = {
    enable = true;
    package = let
      version = "0.7.5";
      src = pkgs.fetchFromGitHub {
        owner = "bitmagnet-io";
        repo = "bitmagnet";
        rev = "v${version}";
        sha256 = "sha256-hyF0SwhMXpM7imjVmxFaX+Z6h9tiZvZszVTEdhUGvFY=";
      };
    in (pkgs.bitmagnet.override rec {
      buildGoModule = args:
        pkgs.buildGo122Module (args
          // {
            inherit src version;
            vendorHash = "sha256-y9RfaAx9AQS117J3+p/Yy8Mn5In1jmZmW4IxKjeV8T8=";
          });
    });
    environment = {
      TMDB_API_KEY = "12492bfcbf6f881563487630c079ba96";
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
      # jellyseerr = {
      #   image = "ghcr.io/hotio/jellyseerr";
      #   autoStart = true;
      #   ports = ["5055:5055"];
      #   environment = {
      #     PUID = "1000";
      #     PGID = "100";
      #     UMASK = "002";
      #     TZ = "${config.time.timeZone}";
      #   };
      #   volumes = [
      #     "${mediaPath}/config/jellyseerr:/config"
      #   ];
      # };
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
