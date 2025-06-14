# Based on https://github.com/immich-app/immich/blob/main/docker/docker-compose.yml
{ config, ... }:
let
  immichVersion = "v1.134.0";
in
{
  services.cloudflared.tunnels.andromeda.ingress = {
    # "immich.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
    "immich.mgrlab.dk" = "http://localhost:2283";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    networks.immich = { };
    containers = rec {
      immich-server = rec {
        image = "ghcr.io/immich-app/immich-server:${immichVersion}";
        # user = "1000:100";
        networking = {
          networks = [
            "default"
            "immich"
          ];
          aliases = [ "immich-server" ];
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
        devices = [ "/dev/dri" ];
        extraOptions = [
          "--gpus=all"
          "--device=nvidia.com/gpu=all"
        ];
      };
      immich-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}-cuda"; # -cuda for Nvidia GPU support
        networking = {
          networks = [ "immich" ];
          aliases = [ "immich-ml" ];
        };
        environment = {
          TZ = config.time.timeZone;
          IMMICH_PORT = "3003";
        };
        dependsOn = [
          "immich-postgres"
          "immich-redis"
        ];
        devices = [ "/dev/dri" ];
        extraOptions = [
          "--gpus=all"
          "--device=nvidia.com/gpu=all"
        ];
        volumes = [
          "/mnt/ssd/services/immich/cache:/cache:rw"
        ];
      };
      immich-postgres = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.3.0-pgvectors0.2.0@sha256:fa4f6e0971f454cd95fec5a9aaed2ed93d8f46725cc6bc61e0698e97dba96da1";
        # user = "1000:100";
        networking = {
          networks = [ "immich" ];
          aliases = [ immich-server.environment.DB_HOSTNAME ];
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
      };
      immich-redis = {
        image = "docker.io/valkey/valkey:8-bookworm@sha256:ff21bc0f8194dc9c105b769aeabf9585fea6a8ed649c0781caeac5cb3c247884";
        networking = {
          networks = [ "immich" ];
          aliases = [ immich-server.environment.REDIS_HOSTNAME ];
        };
        healthcheck.cmd = [ "redis-cli ping || exit 1" ];
      };
    };
  };

  hardware.nvidia-container-toolkit.enable = true; # Enable NVIDIA GPU support
  services.xserver.videoDrivers = [ "nvidia" ];
}
