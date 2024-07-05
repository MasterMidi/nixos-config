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

  sourceStorePath = file: let
    sourcePath = lib.toString file.source;
    sourceName = config.lib.strings.storeFileName (baseNameOf sourcePath);
  in
    if builtins.hasContext sourcePath
    then file.source
    else
      builtins.path {
        path = file.source;
        name = sourceName;
      };

  qBittorrentConf = pkgs.writeText "qBittorrent.conf" (lib.generators.toINI {} {
    LegalNotice = {
      Accepted = true;
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
      "WebUI\RootFolder" = /webui/vuetorrent;
      "WebUI\AlternativeUIEnabled" = true;
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

    # customWebUI = lib.mkOption {
    #   type = lib.types.nullOr lib.types.path;
    #   default = null;
    #   description = "Custom WebUI to use instead of the default one.";
    # };

    umask = lib.mkOption {
      type = lib.types.str;
      default = "0002";
      description = "The umask to use for the qBittorrent service.";
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
      type = types.str;
      default = "/var/lib/qBittorrent/";
      example = "/home/yourUser";
      description = ''
        The path where qBittorrent config and state lives.
      '';
    };

    configDir = mkOption {
      type = types.str;
      description = ''
        The path where the settings will exist.
      '';
      default = cfg.dataDir + "/.config/";
    };

    cacheDir = mkOption {
      type = types.str;
      default = cfg.dataDir + "/.cache/";
    };

    logDir = mkOption {
      type = types.str;
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
        uid = 501;
        description = "qBittorrent service user";
      };
    };

    users.groups = mkIf (cfg.group == defaultGroup) {
      qbittorrent.gid = 500;
    };

    systemd.tmpfiles.rules = [
      # "d '${cfg.dataDir}' 0740 ${cfg.user} ${cfg.group} - -"
      # "d '${cfg.configDir}' 0740 ${cfg.user} ${cfg.group} - -"
      # "C '${cfg.configDir}/qBittorrent.conf' 0740 ${cfg.user} ${cfg.group} - ${qBittorrentConf}"
      # "C+ '${cfg.dataDir}/webui/' - - - - ${sourceStorePath}"
    ];
    # systemd.tmpfiles.settings."qBittorrent" = {
    #   "${cfg.dataDir}"."d" = {
    #     mode = "0660";
    #     inherit (cfg) user group;
    #   };
    #   "${cfg.configDir}"."d" = {
    #     mode = "0660";
    #     inherit (cfg) user group;
    #   };
    #   "${cfg.logDir}"."d" = {
    #     mode = "0660";
    #     inherit (cfg) user group;
    #   };
    # };

    systemd.services = {
      qbittorrent = {
        description = "a Bittorrent service";
        documentation = ["man:qBittorrent-nox(1)"];
        after = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        unitConfig = {
          ConditionPathExists = cfg.dataDir;
        };
        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          # StateDirectory = "qBittorrent";
          # SyslogIdentifier = "qBittorrent";
          ExecStart = "${cfg.package}/bin/qbittorrent-nox --webui-port=${toString cfg.webUIAddress.port}";
          Restart = "on-failure";
          UMask = cfg.umask;
        };
      };
    };
  };
}
