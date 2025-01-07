# Auto-generated using compose2nix v0.2.2-pre.
{
  pkgs,
  lib,
  ...
}: {
  # Runtime
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";
  # TODO: add gpu support to immich https://github.com/aksiksi/compose2nix?tab=readme-ov-file#nvidia-gpu-support
  hardware.nvidia-container-toolkit.enable = true; # Enable NVIDIA GPU support
  services.xserver.videoDrivers = ["nvidia"];

  # Firewall
  networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];

  # Containers
  virtualisation.oci-containers.containers."immich_machine_learning" = {
    image = "ghcr.io/immich-app/immich-machine-learning:release";
    environment = {
      "DB_DATABASE_NAME" = "immich";
      "DB_DATA_LOCATION" = "./postgres";
      "DB_PASSWORD" = "#WG2LF9mUh3q";
      "DB_USERNAME" = "postgres";
      "IMMICH_VERSION" = "release";
      "UPLOAD_LOCATION" = "./library";
    };
    volumes = [
      "immich_model-cache:/cache:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      # "--device=nvidia.com/gpu=all"
      "--network=immich_default"
    ];
  };
  systemd.services."podman-immich_machine_learning" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-immich_default.service"
      "podman-volume-immich_model-cache.service"
    ];
    requires = [
      "podman-network-immich_default.service"
      "podman-volume-immich_model-cache.service"
    ];
    partOf = [
      "podman-compose-immich-root.target"
    ];
    wantedBy = [
      "podman-compose-immich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."immich_microservices" = {
    image = "ghcr.io/immich-app/immich-server:release";
    environment = {
      "DB_DATABASE_NAME" = "immich";
      "DB_DATA_LOCATION" = "./postgres";
      "DB_PASSWORD" = "#WG2LF9mUh3q";
      "DB_USERNAME" = "postgres";
      "IMMICH_VERSION" = "release";
      "UPLOAD_LOCATION" = "./library";
    };
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/services/immich/library:/usr/src/app/upload:rw"
    ];
    cmd = ["start.sh" "microservices"];
    dependsOn = [
      "immich_postgres"
      "immich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network=immich_default"
    ];
  };
  systemd.services."podman-immich_microservices" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-immich_default.service"
    ];
    requires = [
      "podman-network-immich_default.service"
    ];
    partOf = [
      "podman-compose-immich-root.target"
    ];
    upheldBy = [
      "podman-immich_postgres.service"
      "podman-immich_redis.service"
    ];
    wantedBy = [
      "podman-compose-immich-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/etc/localtime"
      "/services/immich/library"
    ];
  };
  virtualisation.oci-containers.containers."immich_postgres" = {
    image = "registry.hub.docker.com/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
    environment = {
      "POSTGRES_DB" = "immich";
      "POSTGRES_PASSWORD" = "#WG2LF9mUh3q";
      "POSTGRES_USER" = "postgres";
    };
    volumes = [
      "/services/immich/postgres:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=database"
      "--network=immich_default"
    ];
  };
  systemd.services."podman-immich_postgres" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-immich_default.service"
    ];
    requires = [
      "podman-network-immich_default.service"
    ];
    partOf = [
      "podman-compose-immich-root.target"
    ];
    wantedBy = [
      "podman-compose-immich-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/services/immich/postgres"
    ];
  };
  virtualisation.oci-containers.containers."immich_redis" = {
    image = "registry.hub.docker.com/library/redis:6.2-alpine@sha256:84882e87b54734154586e5f8abd4dce69fe7311315e2fc6d67c29614c8de2672";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=immich_default"
    ];
  };
  systemd.services."podman-immich_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-immich_default.service"
    ];
    requires = [
      "podman-network-immich_default.service"
    ];
    partOf = [
      "podman-compose-immich-root.target"
    ];
    wantedBy = [
      "podman-compose-immich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."immich_server" = {
    image = "ghcr.io/immich-app/immich-server:release";
    environment = {
      "DB_DATABASE_NAME" = "immich";
      "DB_DATA_LOCATION" = "./postgres";
      "DB_PASSWORD" = "#WG2LF9mUh3q";
      "DB_USERNAME" = "postgres";
      "IMMICH_VERSION" = "release";
      "UPLOAD_LOCATION" = "./library";
    };
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/services/immich/library:/usr/src/app/upload:rw"
    ];
    ports = [
      "2283:3001/tcp"
    ];
    cmd = ["start.sh" "immich"];
    dependsOn = [
      "immich_postgres"
      "immich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      # "--device=nvidia.com/gpu=all"
      "--network-alias=immich-server"
      "--network=immich_default"
    ];
  };
  systemd.services."podman-immich_server" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-immich_default.service"
    ];
    requires = [
      "podman-network-immich_default.service"
    ];
    partOf = [
      "podman-compose-immich-root.target"
    ];
    upheldBy = [
      "podman-immich_postgres.service"
      "podman-immich_redis.service"
    ];
    wantedBy = [
      "podman-compose-immich-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/etc/localtime"
      "/services/immich/library"
    ];
  };

  # Networks
  systemd.services."podman-network-immich_default" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f immich_default";
    };
    script = ''
      podman network inspect immich_default || podman network create immich_default
    '';
    partOf = ["podman-compose-immich-root.target"];
    wantedBy = ["podman-compose-immich-root.target"];
  };

  # Volumes
  systemd.services."podman-volume-immich_model-cache" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect immich_model-cache || podman volume create immich_model-cache
    '';
    partOf = ["podman-compose-immich-root.target"];
    wantedBy = ["podman-compose-immich-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-immich-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
