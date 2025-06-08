{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "hoarder.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    networks.hoarder = {};
    containers = rec {
      hoarder-web = rec {
        image = "ghcr.io/hoarder-app/hoarder:0.21.0";
        networking = {
          networks = ["default" "hoarder"];
          aliases = ["hoarder"];
          ports = {
            webui = {
              host = 3000;
              internal = 3000;
            };
          };
        };
        environment = {
          # OPENAI_API_KEY: ...
          DATA_DIR = "/data";
          MEILI_ADDR = "http://meilisearch:7700";
          NEXTAUTH_URL="https://hoarder.mgrlab.dk";
          BROWSER_WEB_URL = "http://chrome:9222";

          # OIDC setup
          DISABLE_SIGNUPS = "true";
          DISABLE_PASSWORD_AUTH = "true";
          OAUTH_WELLKNOWN_URL = "https://auth.mgrlab.dk/application/o/hoarder/.well-known/openid-configuration";
          OAUTH_CLIENT_ID = "eG29hMDAHC2Uzl7Uxek3jog6GGe9ZQS8nTrlV0JV";
          # OAUTH_SCOPE = "";
          OAUTH_PROVIDER_NAME = "Authentik";
          OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
        };
        secrets.env = {
          OAUTH_CLIENT_SECRET.path = config.sops.secrets.HOARDER_AUTHENTIK_OAUTH_CLIENT_SECRET.path;
          MEILI_MASTER_KEY.path = hoarder-meilisearch.secrets.env.MEILI_MASTER_KEY.path;
          NEXTAUTH_SECRET.path = config.sops.secrets.HOARDER_SECRET.path;
        };
        volumes = [
          "/mnt/ssd/services/hoarder/data:/data"
        ];
        dependsOn = [
          "hoarder-meilisearch"
          "hoarder-chrome"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.http.routers.hoarder.rule=Host(`hoarder.mgrlab.dk`)"
          "traefik.http.routers.hoarder.entrypoints=local"
          "traefik.http.routers.hoarder.service=hoarder"
          "traefik.http.services.hoarder.loadbalancer.server.port=${toString networking.ports.webui.internal}"

          # Monitoring
          "kuma.hoarder.http.name=hoarder"
          "kuma.hoarder.http.url=https://hoarder.mgrlab.dk/health"
        ];
      };
      hoarder-meilisearch = {
        image = "getmeili/meilisearch:v1.11.1";
        networking = {
          networks = ["hoarder"];
          aliases = ["meilisearch"];
        };
        environment = {
          MEILI_NO_ANALYTICS = "true";
        };
        secrets.env = {
          MEILI_MASTER_KEY.path = config.sops.secrets.HOARDER_MEILISEARCH_MASTER_KEY.path;
        };
        volumes = [
          "/mnt/ssd/services/hoarder/meilisearch:/meili_data"
        ];
      };
      hoarder-chrome = {
        image = "gcr.io/zenika-hub/alpine-chrome:123";
        networking = {
          networks = ["hoarder"];
          aliases = ["chrome"];
        };
        commands = [
          "--no-sandbox"
          "--disable-gpu"
          "--disable-dev-shm-usage"
          "--remote-debugging-address=0.0.0.0"
          "--remote-debugging-port=9222"
          "--hide-scrollbars"
        ];
      };
    };
  };
}
