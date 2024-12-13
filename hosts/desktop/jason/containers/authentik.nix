{...}: {
  virtualisation.oci-containers.compose.authetik = {
    enable = true;
    networks.default = {};
    containers = rec {
      server = {
        image = "ghcr.io/goauthentik/server:latest";
        autoUpdate = "registry";
        user = "root";
        networking.networks = ["default"];
        commands = ["server"];
        environment = {
          AUTHENTIK_SECRET_KEY = "ODUbeXlniNntxfbHw4TJGpug4oZGzojPYcsvDbJncJoqBcOEw3";
          AUTHENTIK_ERROR_REPORTING__ENABLED = "false";
          AUTHENTIK_REDIS__HOST = "authentik-redis";
          AUTHENTIK_POSTGRESQL__HOST = "authentik-postgres";
          AUTHENTIK_POSTGRESQL__USER = postgres.environment.POSTGRES_USER;
          AUTHENTIK_POSTGRESQL__NAME = postgres.environment.POSTGRES_DB;
          AUTHENTIK_POSTGRESQL__PASSWORD = "$ervurB42";
        };
        volumes = [
          "/services/media/authentik/media:/media"
          "/services/media/authentik/custom-templates:/templates"
        ];
        ports = [
          "8080:9000"
          "8443:9443"
        ];
        dependsOn = [
          "postgres"
          "redis"
        ];
      };
      worker = {
        image = "ghcr.io/goauthentik/server:latest";
        autoUpdate = "registry";
        user = "root";
        networking.networks = ["default"];
        commands = ["worker"];
        environment = {
          AUTHENTIK_SECRET_KEY = "ODUbeXlniNntxfbHw4TJGpug4oZGzojPYcsvDbJncJoqBcOEw3";
          AUTHENTIK_REDIS__HOST = "authentik-redis";
          AUTHENTIK_POSTGRESQL__HOST = "authentik-postgres";
          AUTHENTIK_POSTGRESQL__USER = postgres.environment.POSTGRES_USER;
          AUTHENTIK_POSTGRESQL__NAME = postgres.environment.POSTGRES_DB;
          AUTHENTIK_POSTGRESQL__PASSWORD = "$ervurB42";
        };
        volumes = [
          "/services/media/authentik/media:/media"
          "/services/media/authentik/custom-templates:/templates"
        ];
        dependsOn = [
          "postgres"
          "redis"
        ];
      };
      redis = {
        image = "docker.io/library/redis:alpine";
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
          "/services/media/authentik/redis:/data"
        ];
      };
      postgres = {
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
          POSTGRES_PASSWORD = "$ervurB42";
          POSTGRES_USER = "authentik";
          POSTGRES_DB = "authentik";
        };
        volumes = [
          "/services/media/authentik/postgres:/var/lib/postgresql/data"
        ];
      };
    };
  };
}
