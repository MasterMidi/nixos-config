{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "jellyseerr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      jellyseerr = {
        image = "ghcr.io/fallenbagel/jellyseerr:develop";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["jellyseerr"];
          ports = {
            webui = {
              host = 5055;
              internal = 5055;
            };
          };
        };
        environment = {
          # PGID = builtins.toString config.users.groups.users.gid;
          # PUID = "1000";
          TZ = config.time.timeZone;
          PORT = "5055";
          # UMASK = "002";
        };
        volumes = [
          "/mnt/ssd/services/jellyseerr/config:/app/config:rw"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.port=5055"
          "traefik.http.routers.jellyseerr.rule=Host(`jellyseerr.mgrlab.dk`)"
          "traefik.http.routers.jellyseerr.entrypoints=local"

          # Monitoring
          "kuma.jellyseerr.http.name=Jellyseerr"
          "kuma.jellyseerr.http.url=https://jellyseerr.mgrlab.dk"
        ];
      };
    };
  };
}