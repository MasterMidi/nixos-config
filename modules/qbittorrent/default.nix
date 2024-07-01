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

  # qBittorrentConf =
  #   if cfg.acceptLegalNotice
  #   then
  #     pkgs.writeText "qBittorrent.conf" (lib.generators.toINI {} {
  #       LegalNotice = {
  #         Accepted = true;
  #       };
  #       Preferences = {
  #         "WebUI\Enabled" = true;
  #         "WebUI\LocalHostAuth" = false;
  #         "WebUI\UseUPnP" = true;
  #       };
  #     })
  #   else pkgs.writeText "qBittorrent.conf" (lib.generators.toINI {} {});

  qBittorrentConf = pkgs.writeText "qBittorrent.conf" (lib.generators.toINI {} {
    LegalNotice = {
      Accepted = true;
    };

    AutoRun = {
      enabled = true;
      program = "chmod -R 664 “%F/”";
    };

    BitTorrent = {
      "Session\DisableAutoTMMByDefault" = false;
      "Session\DisableAutoTMMTriggers\CategorySavePathChanged" = false;
      "Session\DisableAutoTMMTriggers\DefaultSavePathChanged" = false;
      "Session\QueueingSystemEnabled" = false;
      "Session\SubcategoriesEnabled" = true;
      "Session\TempPathEnabled" = true;
    };

    Network = {
      Cookies = "@Invalid()";
    };

    Preferences = {
      "Connection\PortRangeMin" = 62876;
      "Queueing\QueueingEnabled" = false;
      "WebUI\Enabled" = true;
      "WebUI\LocalHostAuth" = false;
      "WebUI\UseUPnP" = true;
    };
  });

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

    acceptLegalNotice = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Accept the legal notice on first run.";
    };

    settings = lib.mkOption {
      type = lib.types.nullOr (lib.types.submodule {
        options = {
          BitTorrent = lib.mkOption {
            type = lib.types.attrsOf lib.types.attrs;
            default = {};
            description = "The settings for the BitTorrent section of qBittorrent.conf";
          };

          Preferences = lib.mkOption {
            type = lib.types.attrsOf lib.types.attrs;
            default = {};
            description = "The settings for the Preferences section of qBittorrent.conf";
          };
        };
      });
      default = null;
      description = "The settings written to qBittorrent.conf";
    };

    customWebUI = lib.mkOption {
      type = lib.type.nullOr lib.types.str;
      default = null;
      description = "Custom WebUI to use instead of the default one.";
    };

    openFirewall = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Expose the webui to the network.";
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

    logDir = mkOption {
      type = path;
      default = "${cfg.dataDir}/log";
      description = ''
        Directory where the qbittorrent logs will be stored,
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.webUIAddress.port];

    systemd.packages = [cfg.package];

    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        uid = 501;
        isSystemUser = true;
        description = "qBittorrent service user";
      };
    };

    users.groups = mkIf (cfg.group == defaultGroup) {
      ${defaultGroup}.gid = 500;
    };

    # systemd.tmpfiles.rules = [
    #   "C ${cfg.configDir}/qBittorrent.conf 0755 ${cfg.user} ${cfg.group} - ${qBittorrentConf}"
    # ];
    systemd.tmpfiles.settings.qBittorrentDirs = {
      # "${cfg.dataDir}".d = {
      #   mode = "0700";
      #   inherit (cfg) user group;
      # };
      # "${cfg.configDir}"."d" = {
      #   mode = "700";
      #   inherit (cfg) user group;
      # };
      # "${cfg.logDir}"."d" = {
      #   mode = "700";
      #   inherit (cfg) user group;
      # };
      # "${cfg.cacheDir}"."d" = {
      #   mode = "700";
      #   inherit (cfg) user group;
      # };
    };

    # [
    #   "f '${cfg.dataDir}/qBittorrent.conf' 0755 ${cfg.user} ${cfg.group} - ${qBittorrentConf}"
    #   "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    #   "d '${cfg.dataDir}/.cache/qBittorrent' 0755 ${cfg.user} ${cfg.group} - -"
    #   "d '${cfg.dataDir}/.config/qBittorrent' 0755 ${cfg.user} ${cfg.group} - -"
    #   "d '${cfg.dataDir}/.local/share/qBittorrent' 0755 ${cfg.user} ${cfg.group} - -"
    # ];

    systemd.services = {
      qbittorrent = {
        description = "a Bittorrent service";
        documentation = ["man:qBittorrent-nox(1)"];
        after = ["network-online.target" "nss-lookup.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = "qBittorrent";
          SyslogIdentifier = "qBittorrent";
          WorkingDirectory = cfg.dataDir;
          ExecStart = "${cfg.package}/bin/qbittorrent-nox --webui-port=${toString cfg.webUIAddress.port}";
          ExecStartPre = initializeAndRun;
          UMask = "0113";
          # BindPaths = ["/var/lib/qBittorrent/.config/qBittorrent.conf:${qBittorrentConf}"];
          # NoNewPrivileges = true;
          # SystemCallArchitectures = "native";
          # ProtectHome = true;
          # ProtectSystem = "strict";
          # PrivateDevices = true;
          # RemoveIPC = true;
          # PrivateMounts = true;
          # RestrictNamespaces = !config.boot.isContainer;
          # RestrictRealtime = true;
          # RestrictSUIDSGID = true;
          # ProtectControlGroups = !config.boot.isContainer;
          # ProtectHostname = true;
          # ProtectKernelLogs = !config.boot.isContainer;
          # ProtectKernelModules = !config.boot.isContainer;
          # ProtectKernelTunables = !config.boot.isContainer;
          # LockPersonality = true;
          # PrivateTmp = !config.boot.isContainer;
        };
      };
    };
  };
}
