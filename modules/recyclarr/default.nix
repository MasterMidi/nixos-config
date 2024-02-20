{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.recyclarr;
  recyclarrPackage = pkgs.recyclarr; # Ensure this is your packaged application

  settingsYaml = (pkgs.formats.yaml {}).generate "settings.yml" (cfg.settings);
  recyclarrYaml = (pkgs.formats.yaml {}).generate "recyclarr.yml" (cfg.config);
in {
  options.services.recyclarr = {
    enable = lib.mkEnableOption "Recyclarr Service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.recyclarr;
      description = "The Recyclarr package to use.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Settings for Recyclarr.";
    };

    config = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      example = lib.literalExample ''

      '';
      description = "Config for the Recyclarr service instances.";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily"; # Default schedule runs every 15 minutes
      description = lib.mdDoc "Systemd timer schedule for running Recyclarr sync.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.recyclarr = {
      description = "Recyclarr Sync Service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/recyclarr sync --config ${recyclarrYaml}";
      };
    };

    systemd.timers.recyclarr = {
      description = "Recyclarr Sync Timer";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = ["" cfg.schedule];
        Persistent = true;
      };
    };
  };
}
