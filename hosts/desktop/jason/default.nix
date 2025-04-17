# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    ./gaming.nix
    ./graphical.nix
    ./hardware-configuration.nix
    ./containers
    ./security.nix
    ./services
    ./sound.nix
    ./system.nix
    ./virtualization.nix
    ./programs
    ./secrets
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.michael = {
    isNormalUser = true;
    # uid = 1000;
    description = "Michael Andreas Graversen";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "podman"
      "docker"
      "uinput" # for ydotool
      "dialout" # for arduino and other serial devices
      "media"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    easyeffects # Audio equalizer and effects
    barrier # Software KVM
    gparted # has to be a systempackage or it wont open
    openrgb # RGB control
    lact
    graphite-cursors
    onlyoffice-bin
    docker-compose
    podman-compose
    polkit_gnome
    pulseaudio
    tree
    lm_sensors
    git
    devenv
  ];

  services.tailscale.enable = true;

  services.mullvad-vpn.enable = true;
  services.resolved.enable = true;

  programs.nix-ld.enable = true;

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
  services.openssh.settings.PermitRootLogin = "yes"; # TODO temporary, REMOVE!!!!

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      57621 # Spotify sync local devices
      24800 # input-leap
    ];
    allowedUDPPorts = [
      5353 # Spotfify discover Connect devices
      24800 # input-leap
    ];
  };

  metrics.netdata = {
    enable = true;
    disableWebUI = false;
  };

  # services.qbittorrent = {
  #   enable = true;
  #   openFirewall = true;
  #   acceptLegalNotice = true;
  #   # customWebUI = inputs.vuetorrent;
  #   group = "media";
  # };

  users.groups.media = {
    gid = 500;
  };

  lollypops.deployment = {
    config-dir = "/etc/nix";
  };

	 services.nix-serve = {
    enable = true;
		package = pkgs.nix-serve-ng;
		openFirewall = true;
		secretKeyFile = "/etc/nixos/hosts/destop/jason/cache-private-key.pem";
  };
}
