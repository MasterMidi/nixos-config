{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "homarr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    networks.jellysearch = {};
    containers = rec {
      jellysearch = {
        image = "domistyle/jellysearch";
        user = "1000:100";
        networking = {
          networks = ["default" "jellysearch"];
        };
        environment = {
          JELLYFIN_URL = "http://jellyfin:8096";
          JELLYFIN_CONFIG_DIR = "/config";

          MEILI_URL = "http://index:7700";
          INDEX_CRON = "0 0 0/2 ? * * *";
        };
        secrets.env = {
          MEILI_MASTER_KEY.path = jellysearch-meilisearch.secrets.env.MEILI_MASTER_KEY.path;
        };
        volumes = [
          "/mnt/ssd/services/jellyfin/config/data/data:/config/data:ro" # a bit weird, but jellyfins db is in "config/data/data/", so mapping is needed
        ];
        labels = [
          "traefik.enable=true"
          "traefik.http.services.jellysearch.loadbalancer.server.port=5000"
          "traefik.http.routers.jellysearch.rule=Host(`jellyfin.mgrlab.dk`) && (QueryRegexp(`searchTerm`, `(.*?)`) || QueryRegexp(`SearchTerm`, `(.*?)`))"
        ];
        dependsOn = ["jellysearch-meilisearch"];
      };

      jellysearch-meilisearch = {
        image = "getmeili/meilisearch:v1.9";
        networking = {
          networks = ["jellysearch"];
          aliases = ["index"];
        };
        volumes = ["/mnt/ssd/services/jellysearch/meilisearch:/meili_data:rw"];
        secrets.env = {
          MEILI_MASTER_KEY.path = config.sops.secrets.JELLYSEARCH_MEILISEARCH_MASTER_KEY.path;
        };
      };
    };
  };
}