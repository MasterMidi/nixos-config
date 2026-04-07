{ pkgs, ... }:
{
  time.timeZone = "Europe/Copenhagen";

  boot.kernelPackages = pkgs.linuxPackages_zen;

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
