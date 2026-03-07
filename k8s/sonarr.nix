{ ... }:
let
  app = "sonarr";
  image = "ghcr.io/hotio/sonarr:nightly";
  PUID = "1000";
  PGID = "100";
  TZ = "Europe/Copenhagen";
  port = 8989;
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
                livenessProbe = {
                  httpGet = {
                    path = "/ping";
                    inherit port;
                  };
                  initialDelaySeconds = 30;
                  periodSeconds = 20;
                  timeoutSeconds = 5;
                  failureThreshold = 3;
                };
                readinessProbe = {
                  httpGet = {
                    path = "/ping";
                    inherit port;
                  };
                  initialDelaySeconds = 20;
                  periodSeconds = 10;
                  failureThreshold = 3;
                };
                ports = {
                  _namedlist = true;
                  http.containerPort = port;
                };
                volumeMounts = {
                  _namedlist = true;
                  config.mountPath = "/config";
                  storage.mountPath = "/storage";
                };
              };
            };
            volumes = {
              _namedlist = true;
              config.hostPath = {
                path = "/mnt/ssd/appdata/sonarr";
                type = "DirectoryOrCreate";
              };
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
