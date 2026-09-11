{ config, lib, ... }:
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
                };

                ports = lib.mkNamedList {
                  http.containerPort = port;
                };

                volumeMounts = lib.mkNamedList {
                  config.mountPath = "/config";
                };
              };
            };
            volumes = lib.mkNamedList {
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
