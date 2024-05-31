{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.bitmagnet;
in {
  options = {
    services.bitmagnet = {
      enable = mkEnableOption (lib.mdDoc "Bitmagnet Service");

      package = mkPackageOption pkgs "bitmagnet" {};

      user = mkOption {
        type = types.str;
        default = "bitmagnet";
        description = "User account under which bitmagnet runs.";
      };

      group = mkOption {
        type = types.str;
        default = "bitmagnet";
        description = "Group under which bitmagnet runs.";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/bitmagnet";
        description = "The directory where Bitmagnet stores its data files.";
      };

      settings = mkOption {
        type = types.attrs;
        default = {
          log.json = false;
        };
        description = "Configuration settings for bitmagnet.";
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables for the Bitmagnet service.";
      };

      postgresHost = mkOption {
        type = types.str;
        # default = "localhost";
        default = "192.168.50.71";
        description = "Postgres host";
      };

      postgresName = mkOption {
        type = types.str;
        default = "bitmagnet";
        description = "Postgres host";
      };

      postgresUser = mkOption {
        type = types.str;
        default = "postgres";
        description = "Postgres user";
      };

      postgresPassword = mkOption {
        type = types.str;
        default = "postgres";
        description = "Postgres password";
      };
    };
  };

  config = mkIf cfg.enable {
    # TODO: make it wait for the containers, or else it will fail on startup
    # systemd.services.bitmagnet = {
    #   description = "Bitmagnet Service";
    #   after = ["network.target"];
    #   requires = ["${config.virtualisation.oci-containers.backend}-postgres.service"];
    #   wantedBy = ["multi-user.target"];
    #   environment =
    #     cfg.environment
    #     // {
    #       POSTGRES_HOST = cfg.postgresHost;
    #       POSTGRES_NAME = cfg.postgresName;
    #       POSTGRES_USER = cfg.postgresUser;
    #       POSTGRES_PASSWORD = cfg.postgresPassword;
    #     };
    #   serviceConfig = {
    #     Type = "simple";
    #     User = cfg.user;
    #     Group = cfg.group;
    #     PreStart = "${cfg.package}/bin/bitmagnet config show";
    #     ExecStart = "${cfg.package}/bin/bitmagnet worker run --keys=http_server --keys=queue_server --keys=dht_crawler";
    #     Restart = "on-failure";
    #     # BindPaths = ["${cfg.dataDir}/.config/bitmagnet/config.yml:${(pkgs.formats.yaml {}).generate "config.yml" cfg.settings}"];

    #     # Environment = let
    #     #   envVars = cfg.environment;
    #     # in
    #     #   lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}=${value}") envVars);
    #   };
    # };

    # systemd.tmpfiles.rules = [
    #   # "f ${cfg.dataDir}/.config/bitmagnet/config.yml 0770 ${cfg.user} ${cfg.group} - ${(pkgs.formats.yaml {}).generate "config.yml" cfg.settings}"
    #   "f ${cfg.dataDir}/.config/bitmagnet/config.yml 0770 ${cfg.user} ${cfg.group} - ${(lib.generators.toYAML {}) cfg.settings}"
    # ];

    # networking.firewall = {
    #   allowedTCPPorts = [3334];
    #   allowedUDPPorts = [3334];
    # };

    # users.users = mkIf (cfg.user == "bitmagnet") {
    #   bitmagnet = {
    #     isSystemUser = true;
    #     group = cfg.group;
    #     home = cfg.dataDir;
    #     uid = 3333;
    #   };
    # };

    # users.groups = mkIf (cfg.group == "bitmagnet") {
    #   bitmagnet.gid = 3333;
    # };

    virtualisation.oci-containers.containers = {
      bitmagnet = {
        image = "ghcr.io/bitmagnet-io/bitmagnet:latest";
        hostname = "bitmagnet";
        autoStart = true;
        environment =
          cfg.environment
          // {
            POSTGRES_HOST = cfg.postgresHost;
            POSTGRES_NAME = cfg.postgresName;
            POSTGRES_USER = cfg.postgresUser;
            POSTGRES_PASSWORD = cfg.postgresPassword;
          };
        ports = [
          "3333:3333"
          "3334:3334/tcp"
          "3334:3334/udp"
        ];
        cmd = [
          "worker"
          "run"
          "--keys=http_server"
          "--keys=queue_server"
          # disable the next line to run without DHT crawler
          "--keys=dht_crawler"
        ];
        dependsOn = ["bitmagnet-postgres"];
        extraOptions = ["--network=host"];
      };

      bitmagnet-postgres = {
        image = "postgres:16-alpine";
        hostname = "bitmagnet-postgres";
        autoStart = true;
        volumes = [
          "/root/data/postgres:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_PASSWORD = cfg.postgresPassword;
          POSTGRES_DB = cfg.postgresName;
          PGUSER = cfg.postgresUser;
        };
        extraOptions = ["--shm-size=1g"];
        ports = ["5432:5432"];
      };

      redis = {
        image = "redis:7-alpine";
        hostname = "bitmagnet-redis";
        autoStart = true;
        entrypoint = "redis-server";
        cmd = ["--save 60 1"];
        volumes = [
          "/root/data/redis:/data"
        ];
        environment = {
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "bitmagnet";
          PGUSER = "postgres";
        };
        ports = ["6379:6379"];
      };
    };
  };
}
