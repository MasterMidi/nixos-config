{ ... }:
{
  flake.nixosModules.avahi =
    { ... }:
    {
      # Add mDNS discovery support to the system with avahi
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        settings = {
          server.use-ipv4 = true;
          publish = {
            disable-publishing = false;
            disable-user-service-publishing = false;
            publish-addresses = true;
            publish-domain = true;
            publish-hinfo = true;
            publish-workstation = true;
          };
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
    };
}
