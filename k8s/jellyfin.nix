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
                env = {
                  _namedlist = true;
                  PUID.value = PUID;
                  PGID.value = PGID;
                  TZ.value = TZ;
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
                };
              };
            };
            volumes = {
              _namedlist = true;
              config.hostPath = {
                path = "/mnt/ssd/appdata/jellyfin/config";
                type = "DirectoryOrCreate";
              };
              media.hostPath = {
                path = "/mnt/hdd/media";
                type = "Directory";
              };
              transcodes.hostPath = {
                path = "/mnt/ssd/appdata/jellyfin/transcodes";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
