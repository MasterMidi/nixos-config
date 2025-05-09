{
  config,
  modules,
  ...
}: {
  imports = [modules.services.tailscale-autoconnect];

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    # required to connect to Tailscale exit nodes
    checkReversePath = "loose";
  };

  # inter-machine VPN
  services.tailscale = {
    enable = true;
    openFirewall = true;
    autoConnect = {
      enable = true;
      apiKeyFile = config.sops.secrets.TAILSCALE_KEY.path;
    };
  };
}
