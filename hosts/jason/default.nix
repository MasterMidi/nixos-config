# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # ./refind.nix
    ./containers
    ./gaming.nix
    ./media-server.nix
  ];

  nix = {
    settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://nix-gaming.cachix.org" # Nix gaming cachix repo
      ];

      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" # Nix gaming cachix key
      ];
    };
  };

  environment.binsh = "${pkgs.dash}/bin/dash";

  boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelModules = ["coretemp"];

  services.logind = {
    powerKey = "suspend";
  };

  # Bootloader
  boot.loader.systemd-boot = {
    enable = false;
    editor = false;
    configurationLimit = 5;
  };
  boot.loader.refind = {
    enable = true;
    theme = pkgs.refindTheme.refind-minimal;
    settings = {
      resolution = "3440 1440";
      big_icon_size = 128;
      small_icon_size = 48;
      dont_scan_dirs = "EFI/nixos,EFI/systemd,EFI/BOOT";
      # dont_scan_dirs = ["EFI/nixos" "EFI/systemd" "EFI/BOOT"];
    };
  };

  boot.plymouth = {
    enable = false;
    logo = pkgs.fetchurl {
      url = "https://nixos.org/logo/nixos-hires.png";
      sha256 = "1ivzgd7iz0i06y36p8m5w48fd8pjqwxhdaavc0pxs7w1g7mcy5si";
    };
    theme = "breeze";
    # theme = "angular_alt";
    # themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["angular_alt"];})];
  };
  services.resolved.enable = true;
  # networking.networkmanager.insertNameservers = ["1.1.1.1" "1.0.0.1"];
  networking.hostName = "jason"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };
  programs.dconf.enable = true;
  programs.dconf.profiles = {
    gdm.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            cursor-theme = config.home-manager.users.michael.home.pointerCursor.name;
          };
        };
      }
    ];
  };
  # services.xserver.desktopManager.gnome.enable = true;

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
    # "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}" # Find out if this is useful
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "nodeadkeys";
  };

  # services.wlr.enable = true;
  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
      };
    };

    # Configure wireplumber
    wireplumber = {
      enable = true;

      # https://github.com/NixOS/nixpkgs/pull/292115
      # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
          bluez_monitor.properties = {
          	["bluez5.enable-sbc-xq"] = true,
          	["bluez5.enable-msbc"] = true,
          	["bluez5.enable-hw-volume"] = true,
          	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
          }
        '')
      ];
    };
  };
  # hardware.pulseaudio.extraConfig = "unload-module module-role-cork"; # Disable mute of audio streams when using phone stream (e.g. teamspeak)

  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot

    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  boot.extraModprobeConfig = "options kvm_amd nested=1";

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = true;
  systemd.targets.suspend.enable = true;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  virtualisation.libvirtd.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true; # Enables support for 32bit libs that steam uses
    extraPackages = with pkgs; [
      # amdvlk
    ];
    extraPackages32 = with pkgs; [
      # driversi686Linux.amdvlk
    ];
  };

  services.hardware.openrgb = {
    # enable = true;
    # motherboard = "amd";
    # package = pkgs.openrgb-with-all-plugins;
  };
  services.udev.packages = [pkgs.openrgb];

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  powerManagement.powertop.enable = false;
  powerManagement.cpuFreqGovernor = "schedutil";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Andreas Graversen";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "input"
      "podman"
      "docker"
      "uinput" # for ydotool
      "dialout" # for arduino and other serial devices
      # "i2c" # maybe for openrgb
    ];
  };

  programs.virt-manager.enable = true;

  # Enable flatpaks
  # services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false; # DON'T EVER SET THIS TRUE WILL RUIN XDG-OPEN FUNCTIONALITY
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config = {
      # common.default = ["gtk"];
      hyprland.default = ["hyprland" "gtk"];
    };
  };

  environment.variables = {
    NIXOS_OZONE_WL = "1"; # Force electron to use wayland
  };

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      corefonts
      noto-fonts
      noto-fonts-cjk-sans # To fix weird font rendering for cjk characters
      unifont
    ];

    fontconfig = {
      antialias = true;
      # defaultFonts = {
      #   serif = ["Ubuntu"];
      #   sansSerif = ["Ubuntu"];
      #   monospace = ["Ubuntu Source"];
      # };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    barrier
    gparted # has to be a systempackage or it wont open
    openrgb
    lact
    graphite-cursors
    qbitmanage
    onlyoffice-bin
    docker-compose
    podman-compose
    polkit_gnome
    pulseaudio
    tree
    lm_sensors
    libsecret
    (git.override {withLibsecret = true;})
    git-credential-manager
  ];

  services.gvfs.enable = true; # for nautlius to work with ttrash and network shares

  services.tailscale.enable = true;

  services.mullvad-vpn.enable = true;

  programs.nix-ld.enable = true;

  security = {
    rtkit.enable = true;
    # Polkit for hyprland to get sudo password prompts
    polkit.enable = true;
    pam.services.hyprlock.text = "auth include login";
  };
  services.gnome.gnome-keyring.enable = true;
  programs = {
    seahorse.enable = true;
    # dconf.enable = lib.mkDefault true;
  };

  services.fstrim.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    # pinentryPackage = pkgs.pinentry-gnome3;
  };
  services.dbus.packages = [pkgs.gcr];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"]; # Allow compiling for ARM on x86_64

  # Allow running AppImages directly from commandline
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      57621 # Spotify sync local devices
      2049 # NFS
      5353 # mDNS
      24800 # input-leap
    ];
    allowedUDPPorts = [
      5353 # Spotfify discover Connect devices
      2049
      5353 # mDNS
      24800 # input-leap
    ];
  };

  # system.nssModules = pkgs.lib.optional true pkgs.nssmdns;
  # system.nssDatabases.hosts = pkgs.lib.optionals true (pkgs.lib.mkMerge [
  #   (pkgs.lib.mkBefore ["mdns4_minimal [NOTFOUND=return]"]) # before resolve
  #   (pkgs.lib.mkAfter ["mdns4"]) # after dns
  # ]);

  system.stateVersion = "23.05"; # Did you read the comment?

  ### TESTING AREA ###
  virtualisation.vfio.enable = false;

  virtualisation.kvmfr = {
    enable = true;
    shm = {
      enable = true;
      size = 64;
      user = "michael";
      group = "libvirtd";
      mode = "0666";
    };
  };

  # services.qbitmanage = {

  # };

  # fileSystems."/export/storage" = {
  #   device = "/mnt/storage/media";
  #   options = ["bind"];
  # };

  # services.nfs.server.enable = true;
  # services.nfs.server.exports = ''
  #   /export         192.168.50.0/24(rw,fsid=0,no_subtree_check)
  #   /export/storage	192.168.50.0/24(rw,nohide,insecure,no_subtree_check)
  # '';

  # users.groups.media = {gid = 500;};

  # users.users = {
  #   media = {
  #     group = "media";
  #     uid = 500;
  #   };

  #   sonarr = {
  #     group = "media";
  #     uid = config.ids.uids.sonarr;
  #   };

  #   qbittorrent = {
  #     group = "media";
  #     uid = 501;
  #   };
  # };
}
