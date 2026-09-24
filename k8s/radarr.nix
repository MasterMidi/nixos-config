{ lib, ... }:
let
  app = "radarr";
  image = "ghcr.io/hotio/radarr:nightly-6.1.1.10317";
  PUID = "1000";
  PGID = "100";
  TZ = "Europe/Copenhagen";
  port = 7878;
in
{
  kubernetes.resources.media-stack = {
    PersistentVolumeClaim."${app}-config" = {
      spec = {
        accessModes = [ "ReadWriteOncePod" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "2Gi";
      };
    };

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
                # livenessProbe = {
                #   httpGet = {
                #     path = "/ping";
                #     inherit port;
                #   };
                #   initialDelaySeconds = 30;
                #   periodSeconds = 20;
                #   timeoutSeconds = 5;
                #   failureThreshold = 3;
                # };
                # readinessProbe = {
                #   httpGet = {
                #     path = "/ping";
                #     inherit port;
                #   };
                #   initialDelaySeconds = 20;
                #   periodSeconds = 10;
                #   failureThreshold = 3;
                # };
                ports = lib.mkNamedList {
                  http.containerPort = port;
                };
                volumeMounts = lib.mkNamedList {
                  config.mountPath = "/config";
                  storage.mountPath = "/storage";
                };
              };
            };
            volumes = lib.mkNamedList {
              config.persistentVolumeClaim.claimName = "${app}-config";
              storage.hostPath = {
                path = "/mnt/hdd";
                type = "Directory";
              };
            };
          };
        };
      };
    };
  };
}
