{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./containers
    ./secrets
    ./services
    ./gaming.nix
    ./mergerfs.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 5;
  };
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

  # Enable networking
  networking.networkmanager.enable = true;

  users.users.michael = {
    isNormalUser = true;
    uid = 1000;
    description = "Michael Andreas Graversen";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
  };

  environment.systemPackages = with pkgs; [
    kitty.terminfo
    (writeShellScriptBin "zip" ''
      ${pkgs.gnutar}/bin/tar cf - $1 -P | ${pkgs.pv}/bin/pv -s $(${pkgs.coreutils}/bin/du -sb $1 | ${pkgs.gawk}/bin/awk '{print $1}') | ${pkgs.gzip}/bin/gzip > $2.tar.gz
    '')
    (writeShellScriptBin "uzip" ''
      ${pkgs.pv}/bin/pv $1 | ${pkgs.gnutar}/bin/tar -x
    '')
    (writeShellScriptBin "rtc" ''
      # Check if any arguments were provided
      if [ $# -eq 0 ]; then
          echo "Usage: $0 command [arguments...]"
          echo "Example: $0 tar -xf some_file.tar"
          exit 1
      fi

      # Run the command in background
      "$@" &

      # Get the job ID of the last background process
      job_id=$!

      # Disown the process so it continues after terminal closes
      disown -h "$job_id"

      # Print confirmation message
      echo "Process started with PID $job_id and disowned"
      echo "It will continue running even if you disconnect"
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.desktopManager.plasma6.enable = true;

  services.mullvad-vpn.enable = true;

  system.stateVersion = "24.05";

  lollypops.deployment = {
    local-evaluation = true;
    # Where on the remote the configuration (system flake) is placed
    config-dir = "/etc/nixos/";

    # SSH connection parameters
    # ssh.host = "${config.networking.hostName}.local";
    ssh.host = "andromeda";
    ssh.user = "root";
    ssh.command = "ssh";
    ssh.opts = [];

    # sudo options
    sudo.enable = false;
    sudo.command = "sudo";
    sudo.opts = [];
  };
}
