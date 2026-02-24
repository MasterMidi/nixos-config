{ ... }:
let
  app = "pocket-id";
  image = "ghcr.io/pocket-id/pocket-id:v2.3";
  port = 1411;
in
{
  kubernetes.resources.media-stack = {
    Secret."${app}-secret" = {
      stringData = {
        MAXMIND_LICENSE_KEY = "{{ secrets.maxmind_license_key }}";
        ENCRYPTION_KEY = "{{ secrets.pocketid_encryption_key }}";
      };
    };

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
                  APP_URL.value = "https://oidc.mgrlab.dk";
                  TRUST_PROXY.value = "true";
                  PUID.value = "1000";
                  PGID.value = "100";

                  ENCRYPTION_KEY = {
                    valueFrom.secretKeyRef = {
                      name = "${app}-secret";
                      key = "ENCRYPTION_KEY";
                    };
                  };
                  MAXMIND_LICENSE_KEY = {
                    valueFrom.secretKeyRef = {
                      name = "${app}-secret";
                      key = "MAXMIND_LICENSE_KEY";
                    };
                  };
                };

                ports = {
                  _namedlist = true;
                  http.containerPort = port;
                };

                volumeMounts = {
                  _namedlist = true;
                  data.mountPath = "/app/data";
                };
              };
            };

            volumes = {
              _namedlist = true;
              data.hostPath = {
                path = "/mnt/ssd/appdata/pocket-id";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
