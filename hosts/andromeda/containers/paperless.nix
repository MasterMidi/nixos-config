{ config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver.containers = {
    paperless-broker = {
      image = "docker.io/library/redis:8";
      volumes = [
        # Bind mount for persistent redis data.
        "/mnt/ssd/services/paperless/data/redis:/data"
      ];
      networking.aliases = [ "broker" ];
    };

    paperless-db = {
      image = "docker.io/library/postgres:17";
      volumes = [
        # Bind mount for the persistent postgresql database.
        "/mnt/ssd/services/paperless/data/postgres:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_DB = "paperless";
        POSTGRES_USER = "paperless";
        POSTGRES_PASSWORD = "paperless";
      };
      networking.aliases = [ "db" ];
    };

    paperless-gotenberg = {
      image = "docker.io/gotenberg/gotenberg:8.20";
      commands = [
        "gotenberg"
        "--chromium-disable-javascript=true"
        "--chromium-allow-list=file:///tmp/.*"
      ];
      networking.aliases = [ "gotenberg" ];
    };

    paperless-tika = {
      image = "docker.io/apache/tika:latest";
      networking.aliases = [ "tika" ];
    };

    paperless-webserver = rec {
      image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
      dependsOn = [
        "paperless-db"
        "paperless-broker"
        "paperless-gotenberg"
        "paperless-tika"
      ];
      networking = {
        networks = [ "default" ];
        aliases = [ "paperless" ];
        ports = {
          webui = {
            host = 8020;
            internal = 8000;
            protocol = "tcp";
          };
        };
      };
      volumes = [
        # Bind mounts for persistent application data and media.
        "/mnt/ssd/services/paperless/data/paperless:/usr/src/paperless/data"
        "/mnt/ssd/services/paperless/media:/usr/src/paperless/media"
        # Bind mounts for import/export directories.
        "/mnt/ssd/services/paperless/export:/usr/src/paperless/export"
        "/mnt/ssd/services/paperless/consume:/usr/src/paperless/consume"
      ];
      environment = {
        PAPERLESS_URL = "https://paperless.mgrlab.dk";
        PAPERLESS_REDIS = "redis://broker:6379";
        PAPERLESS_DBHOST = "db";
        PAPERLESS_TIKA_ENABLED = "1";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://gotenberg:3000";
        PAPERLESS_TIKA_ENDPOINT = "http://tika:9998";
        PAPERLESS_OCR_LANGUAGES = "dan eng";

        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = "True";
        PAPERLESS_SOCIAL_AUTO_SIGNUP = "True";
      };
      secrets.env = {
        PAPERLESS_SOCIALACCOUNT_PROVIDERS.path = config.sops.templates.PAPERLESS_SOCIALACCOUNT_CONFIG.path;
      };
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.paperless.rule=Host(`paperless.mgrlab.dk`)"
        "traefik.http.routers.paperless.entrypoints=local"
        "traefik.http.routers.paperless.service=paperless"
        "traefik.http.services.paperless.loadbalancer.server.port=${toString networking.ports.webui.internal}"
      ];
    };
  };

  sops.templates.PAPERLESS_SOCIALACCOUNT_CONFIG = {
    owner = config.users.users.michael.name;
    group = config.users.groups.users.name;
    restartUnits = [
      config.virtualisation.oci-containers.compose.mediaserver.containers.paperless-webserver.unitName
    ];
    content = builtins.toJSON {
      openid_connect = {
        SCOPE = [
          "openid"
          "profile"
          "email"
        ];
        OAUTH_PKCE_ENABLED = true;
        APPS = [
          {
            provider_id = "pocket-id";
            name = "Pocket ID";
            client_id = "4e5847bf-8fb6-4d83-8ed0-bad787994513";
            secret = config.sops.placeholder.PAPERLESS_POCKETID_CLIENT_SECRET;
            settings = {
              server_url = "https://oidc.mgrlab.dk";
              token_auth_method = "client_secret_post";
            };
          }
        ];
      };
    };
  };
}
