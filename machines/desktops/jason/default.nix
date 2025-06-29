{ pkgs, ... }:
{
  imports = [
    ./filesystem
    ./hardware
    ./home
    ./services
    ./development.nix
    ./gaming.nix
    ./graphical.nix
    ./security.nix
    ./sound.nix
    ./system.nix
    ./virtualization.nix
  ];

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
  services.dbus.packages = [ pkgs.gcr ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  lollypops.deployment = {
    config-dir = "/etc/nix";
  };
}
