{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware
    ./home
    ./secrets
    ./services
    ./networking.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures.
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  powerManagement.powertop.enable = false;
  powerManagement.cpuFreqGovernor = "schedutil";

  services.fstrim.enable = true;

  users.users.michael = {
    isNormalUser = true;
    uid = 1000;
    description = "Michael Andreas Graversen";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  environment.systemPackages = with pkgs; [
    kitty.terminfo
    (writeShellScriptBin "zip" ''
      ${pkgs.gnutar}/bin/tar cf - $1 -P | ${pkgs.pv}/bin/pv -s $(${pkgs.coreutils}/bin/du -sb $1 | ${pkgs.gawk}/bin/awk '{print $1}') | ${pkgs.gzip}/bin/gzip > $2.tar.gz
    '')
    (writeShellScriptBin "uzip" ''
      ${pkgs.pv}/bin/pv $1 | ${pkgs.gnutar}/bin/tar -x
    '')
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  system.stateVersion = "24.05";

  lollypops.deployment = {
    config-dir = "/etc/nixos/";
    ssh.host = "andromeda.router";
  };
}
