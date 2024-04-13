{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.qbittorrent;
  defaultUser = "qbittorrent";
  defaultGroup = defaultUser;

  qBittorrentConf = pkgs.writeText "qBittorrent.conf" ''
    [LegalNotice]
    Accepted=true

    [AutoRun]
    enabled=true
    program=chmod -R 775 “%F/”

    [BitTorrent]
    Session\DisableAutoTMMByDefault=false
    Session\DisableAutoTMMTriggers\CategorySavePathChanged=false
    Session\DisableAutoTMMTriggers\DefaultSavePathChanged=false
    Session\QueueingSystemEnabled=false
    Session\SubcategoriesEnabled=true
    Session\TempPathEnabled=true

    [Network]
    Cookies=@Invalid()

    [Preferences]
    Connection\PortRangeMin=62876
    Queueing\QueueingEnabled=false
  '';

  webUIAddressSubmodule = lib.types.submodule {
    options = {
      address = lib.mkOption {
        default = "127.0.0.1";
        type = lib.types.str;
        description = "The IP address to which the webui will bind.";
      };
      port = lib.mkOption {
        default = 8080;
        type = lib.types.int;
        description = "The port to which the webui will bind.";
      };
    };
  };

  # TODO: replace with tmpfile rule
  initializeAndRun = pkgs.writers.writeBash "initializeAndRun-qBittorrent-config" ''
    set -efu

    mkdir -p ${cfg.configDir}

    if [ ! -f ${cfg.configDir}/qBittorrent.conf ]; then
    	cp ${qBittorrentConf} ${cfg.configDir}/qBittorrent.conf
    fi
  '';
in {
  options.services.qbittorrent = {
    enable = mkEnableOption "Featureful free software BitTorrent client";

    package = mkPackageOption pkgs "qbittorrent-nox" {};

    webUIAddress = mkOption {
      type = webUIAddressSubmodule;
      default = {};
      description = "The IP and port to which the webui will bind.";
    };

    openFirewall = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Expose the webui to the network.";
    };

    systemService = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to auto-launch qBittorrent as a system service.
      '';
    };

    user = mkOption {
      type = types.str;
      default = defaultUser;
      example = "yourUser";
      description = ''
        The user to run qBittorrent as.
        By default, a user named <literal>${defaultUser}</literal> will be created.
      '';
    };

    group = mkOption {
      type = types.str;
      default = defaultGroup;
      example = "yourGroup";
      description = ''
        The group to run Syncthing under.
        By default, a group named <literal>${defaultGroup}</literal> will be created.
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qBittorrent";
      example = "/home/yourUser";
      description = ''
        The path where qBittorrent config and state lives.
      '';
    };

    configDir = mkOption {
      type = types.path;
      description = ''
        The path where the settings will exist.
      '';
      default = cfg.dataDir + "/.config/qBittorrent";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts =
      mkIf cfg.openFirewall [cfg.webUIAddress.port];

    systemd.packages = [cfg.package];

    users.users = mkIf (cfg.systemService && cfg.user == defaultUser) {
      ${defaultUser} = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        uid = 501;
        isSystemUser = true;
        description = "qBittorrent service user";
      };
    };

    users.groups = mkIf (cfg.systemService && cfg.group == defaultGroup) {
      ${defaultGroup}.gid = 500;
    };

    systemd.tmpfiles.rules = [
      # "f '${cfg.dataDir}/qBittorrent.conf' 0755 ${cfg.user} ${cfg.group} - ${qBittorrentConf}"
      # "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
      # "d '${cfg.dataDir}/.cache/qBittorrent' 0755 ${cfg.user} ${cfg.group} - -"
      # "d '${cfg.dataDir}/.config/qBittorrent' 0755 ${cfg.user} ${cfg.group} - -"
      # "d '${cfg.dataDir}/.local/share/qBittorrent' 0755 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services = {
      qbittorrent = mkIf cfg.systemService {
        description = "a Bittorrent service";
        documentation = ["man:qBittorrent-nox(1)"];
        wantedBy = ["multi-user.target"];
        after = ["network-online.target" "nss-lookup.target"];
        serviceConfig = {
          Type = "exec";
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = "qBittorrent";
          SyslogIdentifier = "qBittorrent";
          ExecStart = "${cfg.package}/bin/qbittorrent-nox --webui-port=${toString cfg.webUIAddress.port}";
          ExecStartPre = initializeAndRun;
          # BindPaths = ["/var/lib/qBittorrent/.config/qBittorrent.conf:${qBittorrentConf}"];
          # ProtectHome = true;
          # ProtectSystem = "strict";
          # PrivateTmp = true;
          # PrivateDevices = true;
          # ProtectHostname = true;
          # ProtectClock = true;
          # ProtectKernelTunables = true;
          # ProtectKernelModules = true;
          # ProtectKernelLogs = true;
          # ProtectControlGroups = true;
          # NoNewPrivileges = true;
          # RestrictRealtime = true;
          # RestrictSUIDSGID = true;
          # RemoveIPC = true;
          # PrivateMounts = true;
        };
      };
    };
  };
}
