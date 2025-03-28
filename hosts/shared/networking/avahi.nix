# Add mDNS discovery support to the system
{...}: {
  services.avahi = {
    enable = true;
    ipv4 = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      5353 # mDNS
    ];
    allowedUDPPorts = [
      5353 # mDNS
    ];
  };
}
