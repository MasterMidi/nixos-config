{ pkgs, ... }:
{
  system.stateVersion = "23.05";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security = {
    rtkit.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    onlyoffice-desktopeditors
    polkit_gnome
    libsecret
    (git.override { withLibsecret = true; })
    git-credential-manager
    whereami # easily find nix store path for executable
  ];

  services.tailscale.enable = true;

  programs = {
    seahorse.enable = true;
    dconf.enable = true;
  };

  services.gvfs.enable = true; # for nautlius to work with trash and network shares
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    # pinentryPackage = pkgs.pinentry-gnome3;
  };
  services.dbus.packages = [ pkgs.gcr ];
  services.gnome.gnome-keyring.enable = true;

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  networking.hostName = "meridian";

  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  services.resolved.enable = true;

  networking.firewall.allowedTCPPorts = [ 8081 ];

  # virtualization
  boot.kernelModules = [ "kvm-amd" ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
