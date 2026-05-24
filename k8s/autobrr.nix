{ config, ... }:
let
  app = "autobrr";
  image = "ghcr.io/autobrr/autobrr:v1.79";
  port = 7474;

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
                };

                ports = {
                  _namedlist = true;
                  http.containerPort = port;
                };

                volumeMounts = {
                  _namedlist = true;
                  config.mountPath = "/config";
                };
              };
            };
            volumes = {
              _namedlist = true;
              config.hostPath = {
                path = "/mnt/ssd/appdata/autobrr/config";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
