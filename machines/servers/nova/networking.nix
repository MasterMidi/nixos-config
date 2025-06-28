{ lib, ... }:
{
  networking.hostName = "nova";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  services.resolved.enable = true;
}
