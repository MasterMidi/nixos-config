{ ... }:
let
  app = "jellyseerr";
  image = "docker.io/fallenbagel/jellyseerr:preview-OIDC";
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
                  PORT.value = "5055";
                };
                ports = {
                  _namedlist = true;
                  http.containerPort = 5055;
                };
                volumeMounts = {
                  _namedlist = true;
                  config.mountPath = "/app/config";
                };
              };
            };
            volumes = {
              _namedlist = true;
              config.hostPath = {
                path = "/mnt/ssd/appdata/jellyseerr";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
