{ lib, ... }:
let
  app = "seerr";
  image = "ghcr.io/seerr-team/seerr:preview-new-oidc";
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
        resources.requests.storage = "500Mi";
      };
    };
    Service.${app} = {
      spec = {
        ports = lib.mkNamedList {
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
            containers = lib.mkNamedList {
              ${app} = {
                inherit image;
                env = lib.mkNamedList {
                  PUID.value = PUID;
                  PGID.value = PGID;
                  TZ.value = TZ;
                  PORT.value = "5055";
                };
                ports = lib.mkNamedList {
                  http.containerPort = 5055;
                };
                volumeMounts = lib.mkNamedList {
                  config.mountPath = "/app/config";
                };
              };
            };
            volumes = lib.mkNamedList {
              config.persistentVolumeClaim.claimName = "${app}-config";
            };
          };
        };
      };
    };
  };
}
