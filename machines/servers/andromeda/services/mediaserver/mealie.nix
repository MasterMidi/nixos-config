{
  config,
  ...
}:
{
  # Enable your custom compose module for oci-containers
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      mealie = {
        image = "ghcr.io/mealie-recipes/mealie:nightly";
        # PUID and PGID are now handled by the user and group options.
        user = "1000";
        group = "1000";
				# https://docs.mealie.io/documentation/getting-started/installation/backend-config/
        environment = {
          TZ = config.time.timeZone;
          BASE_URL = "https://mealie.mgrlab.dk";
          MAX_WORKERS = "1";
          WEB_CONCURRENCY = "1";
          ALLOW_SIGNUP = "true";
          ALLOW_PASSWORD_LOGIN = "false"; # Since i only use OIDC

          DB_ENGINE = "postgres";
          POSTGRES_DB = "mealie";
          POSTGRES_PASSWORD = "mealie";
          POSTGRES_PORT = "5432";
          POSTGRES_SERVER = "postgres"; # This works due to the network alias of the postgres container.
          POSTGRES_USER = "mealie";

          OIDC_AUTH_ENABLED = "True";
          OIDC_SIGNUP_ENABLED = "True";
          OIDC_CONFIGURATION_URL = "https://oidc.mgrlab.dk/.well-known/openid-configuration";
          OIDC_CLIENT_ID = "a4603e9d-fb60-439e-b545-8e6db4cac96e";
          OIDC_CLIENT_SECRET = "TGFcb26qWOX70kvBtYdfO0fXHEhkJ4TG";
          OIDC_ADMIN_GROUP = "admin";
          OIDC_PROVIDER_NAME = "Pocket ID";
          OIDC_SCOPES_OVERRIDE = "openid profile email groups";
          OIDC_REMEMBER_ME = "True";
          OIDC_USER_GROUP = "everyone";
          OIDC_AUTO_REDIRECT = "True";
        };
        volumes = [
          # The module uses the backend's volume management.
          # Podman will automatically create 'mealie_data' if it doesn't exist.
          "/mnt/ssd/mealie/config:/app/data:rw"
        ];
        dependsOn = [
          "mealie-postgres"
        ];
        networking = {
          # Connect to the "default" network defined above.
          networks = [ "default" ];
          # Assign a network alias for service discovery.
          aliases = [ "mealie" ];
          # Structured port mapping.
          ports = {
            # The key 'http' is just a descriptive name for the port mapping.
            http = {
              host = 9925;
              internal = 9000;
              protocol = "tcp";
            };
          };
        };
        extraOptions = [
          "--memory=1048576000b"
        ];
      };

      mealie-postgres = {
        image = "postgres:15";
        environment = {
          POSTGRES_PASSWORD = "mealie";
          POSTGRES_USER = "mealie";
        };
        volumes = [
          "/mnt/ssd/mealie/data:/var/lib/postgresql/data:rw"
        ];
        networking = {
          networks = [ "default" ];
          aliases = [ "postgres" ];
        };
        # Healthcheck options are now structured and cleaner.
        healthcheck = {
          cmd = [ "pg_isready" ];
          interval = "30s";
          timeout = "20s";
          retries = 3;
        };
      };
    };
  };
}
