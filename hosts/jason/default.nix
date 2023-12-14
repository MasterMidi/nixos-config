# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, outputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-configuration-overrides.nix
      ./refind.nix
    ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # outputs.overlays.nur-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    # Configure nixpkgs instance
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-25.9.0" # TODO remove when culprit found
      ];
    };

  };

  # inputs.home-manager.useGlobalPkgs = true;
  #       inputs.home-manager.useUserPackages = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.refind = {
    enable = true;
    extraConfig = ''
      include themes/rEFInd-minimal/theme.conf
      resolution 3440 1440
      big_icon_size 128
      small_icon_size 48
    '';
  };

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org" # Hyprland cachix repo
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # Hyprland cachix key
    ];
  };

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
  services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "dk";
    xkbVariant = "nodeadkeys";
  };

  # services.wlr.enable = true;
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Configure wireplumber
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

  boot.extraModprobeConfig = "options kvm_amd nested=1";
  virtualisation.libvirtd.enable = true;
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    enableOnBoot = true;
    storageDriver = "btrfs";
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true; # Enables support for 32bit libs that steam uses
    extraPackages = with pkgs; [ amdvlk ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # nixpkgs.overlays = [
  #   (self: super: {
  #     r2modman = super.r2modman.overrideAttrs (oldAttrs: rec {
  #       version = "3.1.45";
  #       src = super.fetchFromGitHub {
  #         owner = "ebkr";
  #         repo = "r2modmanPlus";
  #         rev = "v${version}";
  #         hash = "sha256-6o6iPDKKqCzt7H0a64HGTvEvwO6hjRh1Drl8o4x+4ew="; # Replace with the actual hash
  #       };
  #       # Update the offlineCache hash only if the dependencies have changed
  #       offlineCache = oldAttrs.offlineCache.overrideAttrs {
  #         hash = "sha256-CXitb/b2tvTfrkFrFv4KP4WdmMg+1sDtC/s2u5ezDfI="; # Update if necessary
  #       };
  #     });
  #   })
  # ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Andreas Graversen";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "input" ];
    packages = with pkgs; [ ];
  };

  programs.virt-manager.enable = true;

  # Enable flatpaks
  # services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # For file menu etc.
      # xdg-desktop-portal-wlr # inferior to xdg-desktop-portal-hyprland
      # xdg-desktop-portal-hyprland
    ];
  };

  environment.sessionVariables = { };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # inputs.home-manager.packages.x86_64-linux.default # Nessesary for home-manager when not as a module
    direnv
    docker-compose
    polkit_gnome
    pulseaudio
    tree
    lm_sensors
    nixd
    nixpkgs-fmt
    libsecret
    (git.override { withLibsecret = true; })
    # git-credential-manager
  ];


  services.tailscale.enable = true;

  services.mullvad-vpn.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.gamemode.enable = true;

  # Polkit for hyprland to get sudo password prompts
  security.polkit.enable = true;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    57621 # Spotify sync local devices
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # Spotfify discover Connect devices
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
