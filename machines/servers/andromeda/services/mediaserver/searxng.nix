{config,...}:{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      searxng = {
        image = "searxng/searxng";
        # autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["searxng"];
          ports = {
            webui = {
              host = 4848;
              internal = 8080;
              protocol = "tcp";
            };
          };
        };
        environment = {
          INSTANCE_NAME="searxng";
          BASE_URL="https://search.mgrlab.dk";
        };
        volumes = [
          "/mnt/ssd/services/searxng:/etc/searxng:rw"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.port: 80"
          "traefik.http.routers.searxng.rule=Host(`search.mgrlab.dk`)"
          "traefik.http.routers.searxng.entrypoints=local"
        ];
      };
    };
  };
}
