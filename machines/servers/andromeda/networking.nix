{ lib, ... }:
{
  networking.hostName = "andromeda";

  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  services.resolved.enable = true;
}
