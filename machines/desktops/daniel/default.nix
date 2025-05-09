# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./development
    ./filesystem
		./hardware
    ./home
    ./hardware.nix
    ./networking.nix
    ./sound.nix
    ./system.nix
    ./user-interface.nix
    ./virtualization.nix
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security = {
    rtkit.enable = true;
    # Polkit for hyprland to get sudo password prompts
    polkit.enable = true;
    pam.services.hyprlock.text = "auth include login";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    onlyoffice-bin
    polkit_gnome
    libsecret
    (git.override {withLibsecret = true;})
    git-credential-manager
  ];

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

  system.stateVersion = "23.05";
}
