{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./server.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "andromeda";

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
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  services.fstrim.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  users.users.michael = {
    isNormalUser = true;
    description = "Michael Andreas Graversen";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
  };

  environment.systemPackages = with pkgs; [kitty.terminfo];

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "24.05";

  lollypops.deployment = {
    local-evaluation = true;
    # Where on the remote the configuration (system flake) is placed
    config-dir = "/etc/nixos/";

    # SSH connection parameters
    # ssh.host = "${config.networking.hostName}.local";
    ssh.host = "192.168.50.229";
    ssh.user = "root";
    ssh.command = "ssh";
    ssh.opts = [];

    # sudo options
    sudo.enable = false;
    sudo.command = "sudo";
    sudo.opts = [];
  };
}
