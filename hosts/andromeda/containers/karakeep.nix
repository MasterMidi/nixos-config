{ config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver = {
    networks.karakeep = { };
    containers = rec {
      karakeep-web = {
        image = "ghcr.io/karakeep-app/karakeep:0.26.0";
        networking = {
          networks = [
            "default"
            "karakeep"
          ];
          aliases = [ "karakeep" ];
        };
        environment = {
          # OPENAI_API_KEY: ...
          DATA_DIR = "/data";
          MEILI_ADDR = "http://meilisearch:7700";
          NEXTAUTH_URL = "https://karakeep.mgrlab.dk";
          BROWSER_WEB_URL = "http://chrome:9222";

          # OIDC setup
          DISABLE_SIGNUPS = "true";
          DISABLE_PASSWORD_AUTH = "true";
          OAUTH_WELLKNOWN_URL = "https://oidc.mgrlab.dk/.well-known/openid-configuration";
          OAUTH_CLIENT_ID = "7eb6f71f-a59e-4f4f-8a09-6d7e45bf3dfd";
          # OAUTH_SCOPE = "";
          OAUTH_PROVIDER_NAME = "Pocket ID";
          OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
        };
        secrets.env = {
          OAUTH_CLIENT_SECRET.path = config.sops.secrets.KARAKEEP_OAUTH_CLIENT_SECRET.path;
          MEILI_MASTER_KEY.path = karakeep-meilisearch.secrets.env.MEILI_MASTER_KEY.path;
          NEXTAUTH_SECRET.path = config.sops.secrets.KARAKEEP_SECRET.path;
        };
        volumes = [
          "/mnt/ssd/services/karakeep/data:/data"
        ];
        dependsOn = [
          "karakeep-meilisearch"
          "karakeep-chrome"
        ];
      };
      karakeep-meilisearch = {
        image = "getmeili/meilisearch:v1.11.1";
        networking = {
          networks = [ "karakeep" ];
          aliases = [ "meilisearch" ];
        };
        environment = {
          MEILI_NO_ANALYTICS = "true";
        };
        secrets.env = {
          MEILI_MASTER_KEY.path = config.sops.secrets.KARAKEEP_MEILISEARCH_MASTER_KEY.path;
        };
        volumes = [
          "/mnt/ssd/services/karakeep/meilisearch:/meili_data"
        ];
      };
      karakeep-chrome = {
        image = "gcr.io/zenika-hub/alpine-chrome:123";
        networking = {
          networks = [ "karakeep" ];
          aliases = [ "chrome" ];
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
