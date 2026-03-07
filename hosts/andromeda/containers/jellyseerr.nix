{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "jellyseerr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      jellyseerr = {
        # image = "ghcr.io/fallenbagel/jellyseerr:develop";
				image = "docker.io/fallenbagel/jellyseerr:preview-OIDC";
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
      };
    };
  };
}
