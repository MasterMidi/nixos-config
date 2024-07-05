{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.recyclarr;

  settingsYaml = (pkgs.formats.yaml {}).generate "settings.yml" (cfg.settings);

  # Function to convert camelCase to snake_case
  camelToSnake = s: let
    upperToLower = c:
      if lib.char.isUpper c
      then "_" + (lib.char.toLower c)
      else lib.toString c;
  in
    lib.concatMapStrings upperToLower s;

  # Function to convert keys to snake_case
  convertKeysToSnake = set:
    lib.foldl' (
      acc: k: let
        newKey = camelToSnake k;
        newVal =
          if builtins.isAttrs set.${k}
          then convertKeysToSnake set.${k}
          else set.${k};
      in
        acc // {${newKey} = newVal;}
    ) {} (lib.attrNames set);

  # Function to convert qualityProfiles attr sets into lists
  convertProfilesToList = set:
    lib.mapAttrs (k: v:
      if k == "qualityProfiles"
      then builtins.attrValues v
      else if builtins.isAttrs v
      then convertProfilesToList v
      else v)
    set;

  # Recursively process all instances of sonarr and radarr
  processInstances = settings:
    lib.mapAttrs (
      serviceName: instances:
        lib.mapAttrs (instanceName: instanceConfig: convertProfilesToList instanceConfig) instances
    )
    settings;

  finalConfig = processInstances cfg.config;

  recyclarrYaml = (pkgs.formats.yaml {}).generate "recyclarr.yml" finalConfig;

  serviceOptions = {
    options = {
      sonarr = serviceInstance;
      radarr = serviceInstance;
    };
  };

  serviceInstance = lib.mkOption {
    type = lib.types.nullOr (lib.types.attrsOf (lib.types.submodule serviceInstanceOptions));
    default = {};
    description = "Settings specific to an instance.";
  };

  serviceInstanceOptions = {name, ...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "default";
        description = "The name of the instance.";
      };

      baseUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:8989";
        description = ''
          The base URL of the service instance.
          Can be ommited if specified in secrets file
        '';
      };

      apiKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          The API key for the service instance.
          Can be ommited if specified in secrets file
        '';
      };

      deleteOldCustomFormats = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Delete old custom formats.";
      };

      replaceExistingCustomFormats = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Replace existing custom formats.";
      };

      mediaNaming = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "The media naming schemes.";
      };

      qualityProfiles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule qualityProfileOptions);
        default = {};
        description = "The quality profiles.";
      };

      customFormats = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule customFormatOptions);
        default = {};
        description = "The custom formats.";
      };
    };

    # Makes the whole "<name>" attribute possible
    config = {name = lib.mkDefault name;};
  };

  qualityProfileOptions = {name, ...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = "The name of the quality profile.";
      };

      resetUnmatchedScores = lib.mkOption {
        type = lib.types.nullOr (lib.types.submodule {
          options = {
            enabled = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable resetting unmatched scores.";
            };

            except = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
              description = "Except for these series.";
            };
          };
        });
        default = null;
        description = "Reset unmatched scores.";
      };

      scoreSet = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Name of the guide-provided, preset scores to use.";
      };

      minFormatScore = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Minimum score for a format to be considered.";
      };

      upgrade = lib.mkOption {
        type = lib.types.nullOr (lib.types.submodule {
          options = {
            allowed = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Allow upgrading.";
            };

            untilQuality = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Upgrade until quality.";
            };

            untilScore = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "Upgrade until score.";
            };
          };
        });
        default = null;
        description = "Upgrade settings.";
      };

      qualitySort = lib.mkOption {
        type = lib.types.str;
        default = "top";
        description = "Sort order for qualities.";
      };

      qualities = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "The name of the quality.";
            };

            enabled = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable this quality.";
            };

            qualities = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
              description = "Qualities used in this quality profile.";
            };
          };
        });
      };
    };

    config = {name = lib.mkDefault name;};
  };

  customFormatOptions = {
    options = {
      trashIds = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Trash IDs to import.";
      };

      qualityProfiles = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "The name of the quality profile.";
            };

            score = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "The override score for the quality profile.";
            };
          };
        });
        default = [];
        description = "Quality profiles to import formats into.";
      };
    };
  };
in {
  options.services.recyclarr = {
    enable = lib.mkEnableOption "Recyclarr Service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.recyclarr;
      description = "The Recyclarr package to use.";
    };

    secretsFile = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "A secrets file to include in the config";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily"; # Default schedule runs every day at midnight
      description = "Systemd timer schedule for running Recyclarr sync.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Settings for Recyclarr.";
    };

    config = lib.mkOption {
      type = lib.types.nullOr (lib.types.submodule serviceOptions);
      default = null;
      example = lib.literalExample ''

      '';
      description = "Config for the Recyclarr service instances.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.recyclarr = {
      description = "Recyclarr Sync Service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/recyclarr sync --config ${recyclarrYaml} --config ${settingsYaml} --config ${cfg.secretsFile}";
      };
    };

    systemd.timers.recyclarr = {
      description = "Recyclarr Sync Timer";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = [cfg.schedule];
        Persistent = true;
      };
    };
  };
}
