{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.qbitmanage;
in {
  options = {
    services.qbitmanage = {
      enable = mkEnableOption (lib.mdDoc "qbitmanage Service");

      package = mkPackageOption pkgs "qbitmanage" {};

      user = mkOption {
        type = types.str;
        default = "qbitmanage";
        description = "User account under which qbitmanage runs.";
      };

      group = mkOption {
        type = types.str;
        default = "qbitmanage";
        description = "Group under which qbitmanage runs.";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/qbitmanage";
        description = "The directory where qbitmanage stores its data files.";
      };

      config = mkOption {
        type = lib.types.str;
        # default = {};
        description = "Configuration for qbitmanage.";
      };

      umask = mkOption {
        type = types.str;
        default = "002";
        description = "The umask to use for the qbitmanage service.";
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables for the qbitmanage service.";
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "qbitmanage") {
      qbitmanage = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        uid = 3333;
      };
    };

    users.groups = mkIf (cfg.group == "qbitmanage") {
      qbitmanage.gid = 3333;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0740 ${cfg.user} ${cfg.group} - -"
      # "d '${cfg.dataDir}/config' 0740 ${cfg.user} ${cfg.group} - -"
      # "f+ '${cfg.dataDir}/config/config.yml' 0740 ${cfg.user} ${cfg.group} - ${cfg.config}"
    ];

    systemd.services = {
      qbitmanage = {
        description = "qbitmanage Service";
        after = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        # unitConfig = {
        #   ConditionPathExists = cfg.dataDir;
        # };
        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = "${cfg.package}/bin/";
          ExecStart = "${cfg.package}/bin/qbitmanage -r";
          BindPaths = ["${cfg.dataDir}/:${cfg.package}/bin/"];
          Restart = "on-failure";
          UMask = cfg.umask;
        };
      };
    };

    # virtualisation.oci-containers.containers = {
    #   qbitmanage = {
    #     image = "ghcr.io/hotio/qbitmanage:nightly";
    #     hostname = "qbitmanage";
    #     user = "${builtins.toString config.users.users."${cfg.user}".uid}:${builtins.toString config.users.groups."${cfg.group}".gid}";
    #     autoStart = true;
    #     environment =
    #       cfg.environment
    #       // {
    #         PUID = builtins.toString config.users.users."${cfg.user}".uid;
    #         PGID = builtins.toString config.users.groups."${cfg.group}".gid;
    #         TZ = config.time.timeZone;
    #         UMASK = cfg.umask;
    #       };
    #     volumes = [
    #       "${cfg.dataDir}/config:/config"
    #       "${cfg.dataDir}/data:/data"
    #       "/home/michael/.temp/data/torrents:/storage/torrents"
    #       "/mnt/storage/media/torrents:/cold/torrents"
    #     ];
    #     extraOptions = ["--network=host"];
    #   };
    # };
  };
}
