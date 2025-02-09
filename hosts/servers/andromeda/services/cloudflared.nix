{pkgs, config, ...}: {
  environment.systemPackages = with pkgs; [cloudflared];

  services.cloudflared = {
    enable = true;
    user = "michael";
    tunnels = {
      andromeda = {
        default = "http_status:404";
        # credentialsFile = config.sops.secrets.CLOUDFLARED_CRED_FILE.path;
        credentialsFile = "/home/michael/.cloudflared/bd33994e-9a65-4228-ab6d-edf9421ac1aa.json";
      };
    };
  };
  
  # needed for cloudflared: https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 7500000;
    "net.core.wmem_max" = 7500000;
  };
}
