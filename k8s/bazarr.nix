{ config, ... }:
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
        ports = {
          _namedlist = true;
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
            containers = {
              _namedlist = true;
              ${app} = {
                inherit image;
                env = {
                  _namedlist = true;
                  PUID.value = PUID;
                  PGID.value = PGID;
                  TZ.value = TZ;
                  # Keeping your debug verbosity
                  VERBOSITY.value = "-vv";
                };

                ports = {
                  _namedlist = true;
                  http.containerPort = port;
                };

                volumeMounts = {
                  _namedlist = true;
                  # Mapping internal /storage/media to your NixOS mount
                  media.mountPath = "/storage/media";
                  config.mountPath = "/config";
                };
              };
            };
            volumes = {
              _namedlist = true;
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
