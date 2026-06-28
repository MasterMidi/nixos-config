{ ... }:
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
        ports = {
          _namedlist = true;
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
            containers = {
              _namedlist = true;
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
                env = {
                  _namedlist = true;
                  TZ.value = TZ;
                };
                ports = {
                  _namedlist = true;
                  http.containerPort = webuiPort;
                  influxdb.containerPort = influxdbPort;
                };
                readinessProbe.tcpSocket.port = webuiPort;
                livenessProbe = {
                  tcpSocket.port = webuiPort;
                  initialDelaySeconds = 60;
                  periodSeconds = 30;
                };
                volumeMounts = {
                  _namedlist = true;
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
            volumes = {
              _namedlist = true;
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
