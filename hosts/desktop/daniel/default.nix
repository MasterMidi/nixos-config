# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./sound.nix
    ./secrets
    ./development
    # ./home-assistant.nix
    # ./testing.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "daniel"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  programs.hyprland = {
    enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Enable networking
  networking.networkmanager.enable = true;

  environment.binsh = "${pkgs.dash}/bin/dash";

  powerManagement.powertop.enable = false;
  powerManagement.cpuFreqGovernor = "schedutil";

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
  services.xserver.desktopManager.gnome.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "nodeadkeys";
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security = {
    rtkit.enable = true;
    # Polkit for hyprland to get sudo password prompts
    polkit.enable = true;
    pam.services.hyprlock.text = "auth include login";
  };

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    extraGroups = ["networkmanager" "wheel" "dialout"];
  };

  boot.plymouth = {
    enable = true;
    logo = pkgs.fetchurl {
      url = "https://nixos.org/logo/nixos-hires.png";
      sha256 = "1ivzgd7iz0i06y36p8m5w48fd8pjqwxhdaavc0pxs7w1g7mcy5si";
    };
    # theme = "breeze";
    theme = "angular_alt";
    themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = [config.boot.plymouth.theme];})];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    onlyoffice-bin
    polkit_gnome
    libsecret
    (git.override {withLibsecret = true;})
    git-credential-manager
    # mullvad-vpn
    rpi-imager
    vdhcoapp
    chromium
  ];

  qt = {
    enable = true;
    platformTheme = "qt5ct"; # Or "qt5ct" for Qt5
    style = "kvantum";
  };

  services.tailscale.enable = true;

  services.mullvad-vpn.enable = true;
  services.resolved.enable = true; # Needed for mullvad to work: https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/8

  programs = {
    seahorse.enable = true;
    dconf.enable = true;
  };

  services.gvfs.enable = true; # for nautlius to work with ttrash and network shares
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    # pinentryPackage = pkgs.pinentry-gnome3;
  };
  services.dbus.packages = [pkgs.gcr];
  services.gnome.gnome-keyring.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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

  lollypops.deployment = {
    config-dir = "/etc/nixos/";
  };

  services.nix-serve = {
    enable = true;
    # package = pkgs.nix-serve-ng;
    openFirewall = true;
    secretKeyFile = "/etc/nixos/hosts/desktop/daniel/cache-private-key.pem";
  };
}
