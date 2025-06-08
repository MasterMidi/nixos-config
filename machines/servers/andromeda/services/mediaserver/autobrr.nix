{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "autobrr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      autobrr = rec {
        image = "ghcr.io/autobrr/autobrr:latest";
        autoUpdate = "registry";
        # user = "1000:100";
        networking = {
          networks = ["default"];
          aliases = ["autobrr"];
          ports = {
            webui = {
              host = 7474;
              internal = 7474;
            };
          };
        };
        environment = {
          TZ = config.time.timeZone;
        };
        volumes = [
          "/mnt/ssd/services/autobrr/config:/config"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.http.routers.autobrr.rule=Host(`autobrr.mgrlab.dk`)"
          "traefik.http.routers.autobrr.entrypoints=local"
          # "traefik.http.routers.autobrr.middlewares=redirect-https"
          "traefik.http.routers.autobrr.service=autobrr"
          "traefik.http.services.autobrr.loadbalancer.server.port=${toString networking.ports.webui.internal}"

          # "traefik.http.middlewares.redirect-https.redirectScheme.scheme=https"
          # "traefik.http.middlewares.redirect-https.redirectScheme.permanent=true"

          # "traefik.http.routers.autobrr-https.rule=Host(`autobrr.mgrlab.dk`)"
          # "traefik.http.routers.autobrr-https.entrypoints=https"
          # "traefik.http.routers.autobrr-https.tls=true"
          # "traefik.http.routers.autobrr-https.tls.certresolver=letsencrypt"
          # "traefik.http.routers.autobrr-https.service=autobrr"

          # Monitoring
          "kuma.autobrr.http.name=Autobrr"
          "kuma.autobrr.http.url=https://autobrr.mgrlab.dk/health"
        ];
      };
    };
  };
}
