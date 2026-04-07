{ ... }:
let
  app = "qui";
in
{
  kubernetes.resources.media-stack = {
    Secret."${app}-secret" = {
      stringData = {
        QUI_OIDC_CLIENT_SECRET = "{{ secrets.qui_oidc_client_secret }}";
      };
    };
    Service.${app} = {
      spec = {
        ports = {
          _namedlist = true;
          http = {
            port = 7476;
            targetPort = 7476;
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
              qui = {
                image = "ghcr.io/autobrr/qui:v1.16";
                ports = {
                  _namedlist = true;
                  http.containerPort = 7476;
                };
                env = {
                  _namedlist = true;
                  QUI__OIDC_ENABLED.value = "true";
                  QUI__OIDC_ISSUER.value = "https://oidc.mgrlab.dk";
                  QUI__OIDC_CLIENT_ID.value = "680fb325-335c-45fc-844e-a6acfc7b18b5";
                  QUI__OIDC_CLIENT_SECRET.valueFrom.secretKeyRef = {
                    name = "${app}-secret";
                    key = "QUI_OIDC_CLIENT_SECRET";
                  };
                  QUI__OIDC_REDIRECT_URL.value = "https://qbit.mgrlab.dk/api/auth/oidc/callback";
                  QUI__CORS_ALLOWED_ORIGINS.value = "https://qbit.mgrlab.dk";
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
                path = "/mnt/ssd/appdata/qui";
                type = "DirectoryOrCreate";
              };
              storage.hostPath = {
                path = "/mnt/hdd";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
