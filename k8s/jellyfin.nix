{ ... }:
let
  app = "jellyfin";
  image = "lscr.io/linuxserver/jellyfin:latest";
  PUID = "1000";
  PGID = "100";
  TZ = "Europe/Copenhagen";
in
{
  kubernetes.resources.media-stack = rec {
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
                };
                ports = {
                  _namedlist = true;
                  http.containerPort = 8096;
                };
                volumeMounts = {
                  _namedlist = true;
                  config.mountPath = "/config";
                  media.mountPath = "/storage/media";
                  transcodes.mountPath = "/transcodes";
                  logs.mountPath = "/logs";
                };
              };
            };
            volumes = {
              _namedlist = true;
              config.persistentVolumeClaim.claimName = "${app}-config";
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
