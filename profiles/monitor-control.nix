{ config, pkgs, ... }:

{
  # 1. Enable the underlying I2C buses
  hardware.i2c.enable = true;
  users.users.michael.extraGroups = [ "i2c" ];

  # 2. Add the out-of-tree ddcci driver to your kernel packages
  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];

  # 3. Explicitly load the ddcci_backlight kernel module at boot
  boot.kernelModules = [
    "i2c-dev"
    "ddcci_backlight"
  ];

  # Optional but recommended: Add brightnessctl to manage it via CLI
  environment.systemPackages = with pkgs; [
    ddcutil
    brightnessctl
  ];
}
