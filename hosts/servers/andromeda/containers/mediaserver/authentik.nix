{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "auth.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.authentik-server.networking.ports.http.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = rec {
      authentik-server = {
        image = "ghcr.io/goauthentik/server:2024.12.1";
        user = "root";
        networking = {
          networks = ["default"];
          aliases = ["authentik-server"];
          ports = {
            http = {
              host = 8080;
              internal = 9000;
            };
            https = {
              host = 8443;
              internal = 9443;
            };
          };
        };
        commands = ["server"];
        environment = {
          # AUTHENTIK_COOKIE_DOMAIN = ".mgrlab.dk";
          AUTHENTIK_HOST = "http://authentik-server:9000";  # This is crucial
          AUTHENTIK_HOST_BROWSER = "https://auth.mgrlab.dk";
          AUTHENTIK_ERROR_REPORTING__ENABLED = "false";
          AUTHENTIK_REDIS__HOST = "authentik-redis";
          AUTHENTIK_POSTGRESQL__HOST = "authentik-postgres";
          AUTHENTIK_POSTGRESQL__USER = authentik-postgres.environment.POSTGRES_USER;
          AUTHENTIK_POSTGRESQL__NAME = authentik-postgres.environment.POSTGRES_DB;
        };
        secrets.env = {
          AUTHENTIK_SECRET_KEY.path = config.sops.secrets.AUTHENTIK_SECRET_KEY.path;
          AUTHENTIK_POSTGRESQL__PASSWORD.path = authentik-postgres.secrets.env.POSTGRES_PASSWORD.path;
        };
        volumes = [
          "/mnt/ssd/services/authentik/media:/media"
          "/mnt/ssd/services/authentik/custom-templates:/templates"
        ];
        dependsOn = [
          "authentik-postgres"
          "authentik-redis"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.port=9000"
          "traefik.http.routers.authentik.rule=Host(`auth.mgrlab.dk`) && PathPrefix(`/outpost.goauthentik.io/`)"
          "traefik.http.middlewares.authentik.forwardauth.address=https://auth.mgrlab.dk/outpost.goauthentik.io/auth/traefik"
          "traefik.http.middlewares.authentik.forwardauth.trustForwardHeader=true"
          "traefik.http.middlewares.authentik.forwardauth.authResponseHeaders=X-authentik-username,X-authentik-groups,X-authentik-entitlements,X-authentik-email,X-authentik-name,X-authentik-uid,X-authentik-jwt,X-authentik-meta-jwks,X-authentik-meta-outpost,X-authentik-meta-provider,X-authentik-meta-app,X-authentik-meta-version"
        ];
      };
      authentik-worker = {
        image = "ghcr.io/goauthentik/server:2024.12.1";
        user = "root";
        networking.networks = ["default"];
        commands = ["worker"];
        environment = {
          AUTHENTIK_REDIS__HOST = "authentik-redis";
          AUTHENTIK_POSTGRESQL__HOST = "authentik-postgres";
          AUTHENTIK_POSTGRESQL__USER = authentik-postgres.environment.POSTGRES_USER;
          AUTHENTIK_POSTGRESQL__NAME = authentik-postgres.environment.POSTGRES_DB;
        };
        secrets.env = {
          AUTHENTIK_SECRET_KEY.path = config.sops.secrets.AUTHENTIK_SECRET_KEY.path;
          AUTHENTIK_POSTGRESQL__PASSWORD.path = authentik-postgres.secrets.env.POSTGRES_PASSWORD.path;
        };
        volumes = [
          "/mnt/ssd/services/authentik/media:/media"
          "/mnt/ssd/services/authentik/custom-templates:/templates"
        ];
        dependsOn = [
          "authentik-postgres"
          "authentik-redis"
        ];
      };
      # authentik-proxy = {
      #   image = "ghcr.io/goauthentik/proxy:2024.12.1";
      #   networking = {
      #     networks = ["default"];
      #     ports = {
      #       http = {
      #         host = 8181;
      #         internal = 9000;
      #       };
      #       https = {
      #         host = 8444;
      #         internal = 9443;
      #       };
      #     };
      #     aliases = ["authentik-proxy"];
      #   };
      #   environment = {
      #     AUTHENTIK_HOST = "http://authentik-server:9000";
      #     AUTHENTIK_HOST_BROWSER = "https://auth.mgrlab.dk";
      #     AUTHENTIK_INSECURE = "true";
      #     # Starting with 2021.9, you can optionally set this too
      #     # when authentik_host for internal communication doesn't match the public URL
      #     # AUTHENTIK_HOST_BROWSER: https://external-domain.tld
      #   };
      #   labels = [
      #       # "traefik.enable: true"
      #       # "traefik.port: ${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.http.host}"
      #       # "traefik.http.routers.authentik.rule: Host(`auth.mgrlab.dk`) && PathPrefix(`/outpost.goauthentik.io/`)"
      #       # # `authentik-proxy` refers to the service name in the compose file.
      #       # "traefik.http.middlewares.authentik.forwardauth.address: http://mediaserver-authentik-proxy:8081/outpost.goauthentik.io/auth/traefik"
      #       # "traefik.http.middlewares.authentik.forwardauth.trustForwardHeader: true"
      #       # "traefik.http.middlewares.authentik.forwardauth.authResponseHeaders: X-authentik-username,X-authentik-groups,X-authentik-entitlements,X-authentik-email,X-authentik-name,X-authentik-uid,X-authentik-jwt,X-authentik-meta-jwks,X-authentik-meta-outpost,X-authentik-meta-provider,X-authentik-meta-app,X-authentik-meta-version"
      #       "traefik.enable=true"
      #       "traefik.http.routers.authentik-proxy.rule=Host(`auth.example.org`) && PathPrefix(`/outpost.goauthentik.io/`)"
      #       # `authentik-proxy` refers to the service name in the compose file.
      #       "traefik.http.middlewares.authentik-proxy.forwardauth.address=http://authentik-proxy:9000/outpost.goauthentik.io/auth/traefik"
      #       "traefik.http.middlewares.authentik-proxy.forwardauth.trustForwardHeader=true"
      #       "traefik.http.middlewares.authentik-proxy.forwardauth.authResponseHeaders=X-authentik-username,X-authentik-groups,X-authentik-email,X-authentik-name,X-authentik-uid,X-authentik-jwt,X-authentik-meta-jwks,X-authentik-meta-outpost,X-authentik-meta-provider,X-authentik-meta-app,X-authentik-meta-version"
      #       "traefik.http.services.authentik-proxy.loadbalancer.server.port=9000"

      #       # Monitoring
      #     "kuma.authentik.http.name=Authentik Server"
      #     "kuma.authentik.http.url=https://auth.mgrlab.dk"
      #   ];
      # }; 
      authentik-redis = {
        image = "docker.io/library/redis:7-alpine";
        autoUpdate = "registry";
        user = "root";
        networking = {
          networks = ["default"];
          aliases = ["authentik-redis"];
        };
        commands = ["--save 60 1" "--loglevel warning"];
        healthcheck = {
          cmd = ["CMD-SHELL" "redis-cli ping | grep PONG"];
          startPeriod = "20s";
          interval = "30s";
          retries = 5;
          timeout = "3s";
        };
        volumes = [
          "/mnt/ssd/services/authentik/redis:/data"
        ];
      };
      authentik-postgres = {
        image = "docker.io/library/postgres:16-alpine";
        autoUpdate = "registry";
        user = "root";
        networking = {
          networks = ["default"];
          aliases = ["authentik-postgres"];
        };
        healthcheck = {
          cmd = ["CMD-SHELL" "pg_isready -d \$\${POSTGRES_DB} -U \$\${POSTGRES_USER}"];
          startPeriod = "20s";
          interval = "30s";
          retries = 5;
          timeout = "5s";
        };
        environment = {
          POSTGRES_USER = "authentik";
          POSTGRES_DB = "authentik";
        };
        secrets.env = {
          POSTGRES_PASSWORD.path = config.sops.secrets.AUTHENTIK_POSTGRES_PASSWORD.path;
        };
        volumes = [
          "/mnt/ssd/services/authentik/postgres:/var/lib/postgresql/data"
        ];
      };
    };
  };
}