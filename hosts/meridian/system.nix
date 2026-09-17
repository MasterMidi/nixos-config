{ pkgs, ... }:
{
  time.timeZone = "Europe/Copenhagen";

  boot.kernelPackages = pkgs.linuxPackages_zen;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 15;
    freeMemKillThreshold = 10;
    # Do not let free disk swap postpone intervention until the desktop is unresponsive.
    freeSwapThreshold = 100;
    freeSwapKillThreshold = 100;
    extraArgs = [
      "--avoid"
      "(^|/)(Hyprland)$"
    ];
  };

  # Bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 10;
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
