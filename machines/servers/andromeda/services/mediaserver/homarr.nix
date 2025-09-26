{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "homarr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      homarr = {
        image = "ghcr.io/ajnart/homarr:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["homarr"];
          ports = {
            webui = {
              host = 9000;
              internal = 7575;
            };
          };
        };
        volumes = [
          "/mnt/ssd/services/homarr/configs:/app/data/configs"
          "/mnt/ssd/services/homarr/data:/data"
          "/mnt/ssd/services/homarr/icons:/app/public/icons"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.port=7575"
          "traefik.http.routers.homarr.rule=Host(`homarr.mgrlab.dk`)"
          "traefik.http.routers.homarr.entrypoints=local"
        ];
      };
    };
  };
}