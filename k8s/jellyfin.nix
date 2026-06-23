{ ... }:
let
  app = "jellyfin";
  image = "lscr.io/linuxserver/jellyfin:latest";
  PUID = "1000";
  PGID = "100";
  TZ = "Europe/Copenhagen";

  jellyfinLogging = {
    Serilog = {
      Using = [
        "Serilog.Sinks.Console"
        "Serilog.Formatting.Compact"
        "Serilog.Enrichers.Thread"
      ];

      MinimumLevel = {
        Default = "Information";

        Override = {
          "Microsoft" = "Warning";
          "Microsoft.AspNetCore" = "Warning";
          "Microsoft.EntityFrameworkCore" = "Warning";
          "Microsoft.Hosting.Lifetime" = "Information";
          "System" = "Warning";
          "System.Net.Http.HttpClient" = "Warning";

          "Jellyfin" = "Information";
          "MediaBrowser" = "Information";
          "Emby.Server.Implementations" = "Information";

          # Temporarily enable while debugging:
          # "MediaBrowser.MediaEncoding" = "Debug";
          # "Jellyfin.Api" = "Debug";
          # "Jellyfin.Plugin.Dlna" = "Debug";
          # "Jellyfin.Plugin.Webhook" = "Debug";
        };
      };

      Enrich = [
        "FromLogContext"
        "WithThreadId"
      ];

      Properties = {
        service = "jellyfin";
        component = "media-server";
        log_format = "serilog-rendered-compact-json";
      };

      WriteTo = [
        {
          Name = "Console";
          Args = {
            formatter = "Serilog.Formatting.Compact.RenderedCompactJsonFormatter, Serilog.Formatting.Compact";
          };
        }
      ];
    };
  };

  loggingJson = builtins.toJSON jellyfinLogging;
  loggingHash = builtins.hashString "sha256" loggingJson;
in
{
  kubernetes.resources.media-stack = rec {
    ConfigMap.jellyfin-logging.data."logging.json" = loggingJson;

    PersistentVolumeClaim."${app}-config" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "100Gi";
      };
    };
    Service.${app} = {
      spec = {
        ports = {
          _namedlist = true;
          http = {
            port = Deployment.${app}.spec.template.spec.containers.${app}.ports.http.containerPort;
            targetPort = Deployment.${app}.spec.template.spec.containers.${app}.ports.http.containerPort;
          };
        };
        selector = { inherit app; };
      };
    };
    Deployment.${app} = {
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = { inherit app; };
        template = {
          metadata.labels = { inherit app; };
          metadata.annotations."checksum/jellyfin-logging" = loggingHash;
          spec = {
            runtimeClassName = "nvidia";
            containers = {
              _namedlist = true;
              ${app} = {
                inherit image;
                resources.limits."nvidia.com/gpu" = 1;
                imagePullPolicy = "Always";
                env = {
                  _namedlist = true;
                  PUID.value = PUID;
                  PGID.value = PGID;
                  TZ.value = TZ;

                  # Return memory to system more aggresively
                  MALLOC_TRIM_THRESHOLD_.value = "100000";

                  JELLYFIN_LOG_DIR.value = "/logs";
                  JELLYFIN_CONFIG_DIR.value = "/config";
                };
                ports = {
                  _namedlist = true;
                  http.containerPort = 8096;
                };
                volumeMounts = {
                  _namedlist = true;
                  config.mountPath = "/config";
                  jellyfin-logging = {
                    mountPath = "/config/logging.json";
                    subPath = "logging.json";
                  };
                  media.mountPath = "/storage/media";
                  transcodes.mountPath = "/transcodes";
                  logs.mountPath = "/logs";
                };
              };
            };
            volumes = {
              _namedlist = true;
              config.persistentVolumeClaim.claimName = "${app}-config";
              jellyfin-logging.configMap.name = "jellyfin-logging";
              media.hostPath = {
                path = "/mnt/hdd/media";
                type = "Directory";
              };
              transcodes.emptyDir = { };
              logs.emptyDir = {
                sizeLimit = "100Mi";
              };
            };
          };
        };
      };
    };
  };
}
