{ lib, ... }:
{
  networking.hostName = "daniel";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  services.resolved.enable = true;

  networking.firewall.allowedTCPPorts = [ 8081 ];
}
