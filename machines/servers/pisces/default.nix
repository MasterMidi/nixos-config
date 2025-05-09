{modulesPath, ...}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
    ./hardware
    ./home-automation
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf for u-boot support
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "pisces";

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.raspi = {
    isNormalUser = true;
    description = "Raspberry Pi 3B v1.2";
    extraGroups = ["networkmanager" "wheel"];
    hashedPassword = "$y$j9T$gGYH3.06eDEcKfalPhHPb.$ioKMb3Nw3jtFPvlrYpwkaH7HR4V2.o5mHgq.b9lmx30";
  };
  users.users.root = {
    hashedPassword = "$y$j9T$gGYH3.06eDEcKfalPhHPb.$ioKMb3Nw3jtFPvlrYpwkaH7HR4V2.o5mHgq.b9lmx30";
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true; # set to true if you want the password prompt

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  hardware.enableRedistributableFirmware = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # networking.wireless = {
  #   enable = true;
  #   networks = {
  #     "FTTH_IH5728" = {
  #       psk = "Garshud7Drew";
  #     };
  #   };
  # };

  hardware = {
    bluetooth.enable = true;
    # raspberry-pi = {
    #   config = {
    #     all = {
    #       base-dt-params = {
    #         # enable autoprobing of bluetooth driver
    #         # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
    #         krnbt = {
    #           enable = true;
    #           value = "on";
    #         };
    #       };
    #     };
    #   };
    # };
  };

  lollypops.deployment = {
    ssh.host = "192.168.1.120";
  };

  system.stateVersion = "24.11";

  # Improve performance
  boot.kernel.sysctl = {
    "vm.swappiness" = 10; # Reduce swapping
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
