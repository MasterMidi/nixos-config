{ lib, ... }:
let
  app = "scrutiny";
  image = "ghcr.io/analogj/scrutiny:master-omnibus";
  TZ = "Europe/Copenhagen";
  webuiPort = 8080;
  influxdbPort = 8086;

  commonLabels = {
    inherit app;
    "app.kubernetes.io/name" = app;
    "app.kubernetes.io/part-of" = "media-stack";
  };
in
{
  kubernetes.resources.media-stack = {
    PersistentVolumeClaim."${app}-config" = {
      metadata.labels = commonLabels;
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "1Gi";
      };
    };

    PersistentVolumeClaim."${app}-data" = {
      metadata.labels = commonLabels;
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "10Gi";
      };
    };

    Service.${app} = {
      metadata.labels = commonLabels;
      spec = {
        selector = { inherit app; };
        ports = lib.mkNamedList {
          http = {
            port = 8888;
            targetPort = webuiPort;
          };
          influxdb = {
            port = influxdbPort;
            targetPort = influxdbPort;
          };
        };
      };
    };

    Deployment.${app} = {
      metadata.labels = commonLabels;
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = { inherit app; };
        template = {
          metadata.labels = commonLabels;
          spec = {
            nodeSelector."kubernetes.io/hostname" = "andromeda";
            containers = lib.mkNamedList {
              ${app} = {
                inherit image;
                imagePullPolicy = "Always";
                securityContext.capabilities.add = [
                  "SYS_ADMIN"
                  "SYS_RAWIO"
                ];
                resources = {
                  requests = {
                    cpu = "50m";
                    memory = "256Mi";
                  };
                  limits.memory = "1Gi";
                };
                env = lib.mkNamedList {
                  TZ.value = TZ;
                };
                ports = lib.mkNamedList {
                  http.containerPort = webuiPort;
                  influxdb.containerPort = influxdbPort;
                };
                readinessProbe.tcpSocket.port = webuiPort;
                livenessProbe = {
                  tcpSocket.port = webuiPort;
                  initialDelaySeconds = 60;
                  periodSeconds = 30;
                };
                volumeMounts = lib.mkNamedList {
                  config.mountPath = "/opt/scrutiny/config";
                  data.mountPath = "/opt/scrutiny/influxdb";
                  udev = {
                    mountPath = "/run/udev";
                    readOnly = true;
                  };
                  sda.mountPath = "/dev/sda";
                  sdb.mountPath = "/dev/sdb";
                  sdc.mountPath = "/dev/sdc";
                };
              };
            };
            volumes = lib.mkNamedList {
              config.persistentVolumeClaim.claimName = "${app}-config";
              data.persistentVolumeClaim.claimName = "${app}-data";
              udev.hostPath = {
                path = "/run/udev";
                type = "Directory";
              };
              sda.hostPath = {
                path = "/dev/sda";
                type = "BlockDevice";
              };
              sdb.hostPath = {
                path = "/dev/sdb";
                type = "BlockDevice";
              };
              sdc.hostPath = {
                path = "/dev/sdc";
                type = "BlockDevice";
              };
            };
          };
        };
      };
    };
  };
}
