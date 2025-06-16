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
        environment = {
          ALLOW_SIGNUP = "true";
          # The BASE_URL should be set here if you use a reverse proxy.
          BASE_URL = "https://mealie.mgrlab.dk";
          DB_ENGINE = "postgres";
          MAX_WORKERS = "1";
          POSTGRES_DB = "mealie";
          POSTGRES_PASSWORD = "mealie";
          POSTGRES_PORT = "5432";
          POSTGRES_SERVER = "postgres"; # This works due to the network alias of the postgres container.
          POSTGRES_USER = "mealie";
          TZ = config.time.timeZone;
          WEB_CONCURRENCY = "1";
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
