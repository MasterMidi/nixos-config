{ config, lib, ... }:
let
  app = "bazarr";
  image = "lscr.io/linuxserver/bazarr:latest";
  port = 6767;

  PUID = "1000";
  PGID = "100";
  TZ = "Europe/Copenhagen";
in
{
  kubernetes.resources.media-stack = {
    Service.${app} = {
      spec = {
        ports = lib.mkNamedList {
          http = {
            inherit port;
            targetPort = port;
          };
        };
        selector = { inherit app; };
      };
    };

    Deployment.${app} = {
      spec = {
        replicas = 1;
        # Recreate prevents multiple pods from locking the database/config files
        strategy.type = "Recreate";
        selector.matchLabels = { inherit app; };
        template = {
          metadata.labels = { inherit app; };
          spec = {
            containers = lib.mkNamedList {
              ${app} = {
                inherit image;
                env = lib.mkNamedList {
                  PUID.value = PUID;
                  PGID.value = PGID;
                  TZ.value = TZ;
                  # Keeping your debug verbosity
                  VERBOSITY.value = "-vv";
                };

                ports = lib.mkNamedList {
                  http.containerPort = port;
                };

                volumeMounts = lib.mkNamedList {
                  # Mapping internal /storage/media to your NixOS mount
                  media.mountPath = "/storage/media";
                  config.mountPath = "/config";
                };
              };
            };
            volumes = lib.mkNamedList {
              media.hostPath = {
                path = "/mnt/hdd/media";
                type = "Directory";
              };
              config.hostPath = {
                path = "/mnt/ssd/services/bazarr2/config";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
