{ pkgs, ... }:
{
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  boot.kernelPackages = pkgs.linuxPackages_rpi3;

  boot.loader.raspberryPi.bootloader = "kernel";

  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];
}
