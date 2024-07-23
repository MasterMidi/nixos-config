{
  pkgs,
  lib,
  config,
  ...
}: {
  # inital Nixos version
  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "jason";
  services.resolved.enable = true;

  # Set kernel package
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 5;
  };
  boot.loader.refind = {
    enable = false;
    theme = pkgs.refindTheme.refind-minimal;
    settings = {
      resolution = "3440 1440";
      big_icon_size = 128;
      small_icon_size = 48;
      dont_scan_dirs = "EFI/nixos,EFI/systemd,EFI/BOOT";
      # dont_scan_dirs = ["EFI/nixos" "EFI/systemd" "EFI/BOOT"];
    };
  };

  # System behaviour
  services.logind = {
    powerKey = "suspend";
  };

  systemd.targets = {
    sleep.enable = true;
    suspend.enable = true;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # Hardware code and firmware
  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  # Set powermanagement options
  boot.kernelModules = ["coretemp"]; # for powertop
  boot.kernelParams = ["amd_pstate=active"];
  powerManagement = {
    powertop.enable = false;
    cpuFreqGovernor = "schedutil";
  };

  # Allow compiling for ARM on x86_64
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Allow running AppImages directly from commandline
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
