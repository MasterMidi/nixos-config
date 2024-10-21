{pkgs, ...}: {
  environment.systemPackages = with pkgs; [cloudflared];

  services.cloudflared = {
    enable = true;
    user = "michael";
    tunnels = {
      media_server = {
        default = "http_status:404";
        ingress = {
          "jellyseerr.mgrlab.dk" = "http://localhost:5055";
          "jellyfin.mgrlab.dk" = "http://localhost:9010";
          "ssh.mgrlab.dk" = "ssh://localhost:22";
          "immich.mgrlab.dk" = "http://andromeda:2283";
          "qbit.mgrlab.dk" = "http://localhost:9060";
          "radarr.mgrlab.dk" = "http://localhost:9030";
          "sonarr.mgrlab.dk" = "http://localhost:9040";
        };
      };
    };
  };
}
