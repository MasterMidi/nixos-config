# Based on https://github.com/immich-app/immich/blob/main/docker/docker-compose.yml
{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    # "immich.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
    "immich.mgrlab.dk" = "http://localhost:2283";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    networks.immich = {};
    containers = rec {
      immich-server = rec {
        image = "ghcr.io/immich-app/immich-server:v1.124.2";
        # user = "1000:100";
        networking = {
          networks = ["default" "immich"];
          aliases = ["immich-server"];
          ports = {
            webui = {
              host = 2283;
              internal = 2283;
              protocol = "tcp";
            };
          };
        };
        environment = {
          TZ = config.time.timeZone;
          IMMICH_PORT = "2283";
          UPLOAD_LOCATION = "./library";

          # Database
          DB_HOSTNAME = "database";
          DB_DATABASE_NAME = immich-postgres.environment.POSTGRES_DB;
          DB_USERNAME = immich-postgres.environment.POSTGRES_USER;

          # Redis
          REDIS_HOSTNAME = "redis";
        };
        secrets.env = {
          DB_PASSWORD.path = immich-postgres.secrets.env.POSTGRES_PASSWORD.path;
        };
        volumes = [
          "/etc/localtime:/etc/localtime:ro"
          "/mnt/ssd/media/immich/library:/usr/src/app/upload:rw"
        ];
        labels = [
          "traefik.enable=true"
          # increase readingTimeouts for the entrypoint used here
          "traefik.http.routers.immich.entrypoints=local"
          "traefik.http.routers.immich.rule=Host(`immich.mgrlab.dk`)"
          "traefik.http.services.immich.loadbalancer.server.port=${toString networking.ports.webui.internal}"
        ];
        dependsOn = [
          "immich-postgres"
          "immich-redis"
        ];
        devices = ["/dev/dri"];
        extraOptions = [
          "--gpus=all"
          "--device=nvidia.com/gpu=all"
        ];
      };
      immich-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:v1.124.2";
        networking = {
          networks = ["immich"];
          aliases = ["immich-ml"];
        };
        environment = {
          TZ = config.time.timeZone;
          IMMICH_PORT = "3003";
        };
        dependsOn = [
          "immich-postgres"
          "immich-redis"
        ];
        devices = ["/dev/dri"];
        extraOptions = [
          "--gpus=all"
          "--device=nvidia.com/gpu=all"
        ];
        volumes = [
          "/mnt/ssd/services/immich/cache:/cache:rw"
        ];
      };
      immich-postgres = {
        image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
        # user = "1000:100";
        networking = {
          networks = ["immich"];
          aliases = [immich-server.environment.DB_HOSTNAME];
        };
        environment = {
          POSTGRES_DB = "immich";
          POSTGRES_USER = "postgres";
          POSTGRES_INITDB_ARGS = "--data-checksums";
          DB_DATA_LOCATION = "./postgres";
        };
        secrets.env = {
          POSTGRES_PASSWORD.path = config.sops.secrets.IMMICH_POSTGRES_PASSWORD.path;
        };
        volumes = [
          "/mnt/ssd/services/immich/postgres:/var/lib/postgresql/data:rw"
        ];
#         healthcheck = {
#           cmd = [''
# pg_isready --dbname="$''${POSTGRES_DB}" --username="$''${POSTGRES_USER}" || exit 1;
# Chksum="$$(psql --dbname="$''${POSTGRES_DB}" --username="$''${POSTGRES_USER}" --tuples-only --no-align
# --command='SELECT COALESCE(SUM(checksum_failures), 0) FROM pg_stat_database')";
# echo "checksum failure count is $$Chksum";
# [ "$$Chksum" = '0' ] || exit 1
#           ''];
#           startPeriod = "5m";
#           interval = "5m";
#           timeout = "3s";
#         };
        # commands = [
        #   "postgres"
        #   "-c shared_preload_libraries=vectors.so"
        #   ''-c 'search_path="$$user", public, vectors' ''
        #   "-c logging_collector=on"
        #   "-c max_wal_size=2GB"
        #   "-c shared_buffers=512MB"
        #   "-c wal_compression=on"
        # ];
      };
      immich-redis = {
        image = "docker.io/redis:6.2-alpine@sha256:905c4ee67b8e0aa955331960d2aa745781e6bd89afc44a8584bfd13bc890f0ae";
        networking = {
          networks = ["immich"];
          aliases = [immich-server.environment.REDIS_HOSTNAME];
        };
        healthcheck.cmd = ["redis-cli ping || exit 1"];
      };
    };
  };
  
  hardware.nvidia-container-toolkit.enable = true; # Enable NVIDIA GPU support
  services.xserver.videoDrivers = ["nvidia"];
}
