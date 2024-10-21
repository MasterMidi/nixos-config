{config, ...}: {
  imports = [
    ./solaar.nix
    ./cloudflared.nix
  ];

  services.i2pd = {
    enable = true;
    enableIPv6 = true;
    port = 30777;
    address = "127.0.0.1";
    bandwidth = 1024 * 10; # 1MB/s -> 10MB/s
    floodfill = true;
    upnp.enable = true;
    proto = {
      # enable webconsole
      http = {
        enable = true;
        port = 7070;
      };
      # enable i2cp
      i2cp = {
        enable = true;
        port = 7654;
      };

      # enable socks proxy
      socksProxy = {
        enable = true;
      };

      # enable http proxy
      httpProxy = {
        enable = true;
      };

      i2pControl = {
        enable = true;
        port = 7650;
      };

      # enable SAM
      sam = {
        enable = true;
        port = 7656;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [config.services.i2pd.port];
    allowedUDPPorts = [config.services.i2pd.port];
  };
}
