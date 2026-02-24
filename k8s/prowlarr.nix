{ ... }:
let
  app = "prowlarr";
  image = "ghcr.io/hotio/prowlarr:nightly";
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
                  http.containerPort = 9696;
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
                path = "/mnt/ssd/appdata/prowlarr";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
