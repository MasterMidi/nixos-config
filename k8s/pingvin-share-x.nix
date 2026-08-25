{ ... }:
let
  app = "pingvin-share-x";
  image = "docker.io/smp46/pingvin-share-x:v1.22.1";
  port = 3000;
in
{
  kubernetes.resources.media-stack = {
    Secret."${app}-config" = {
      type = "Opaque";
      stringData."config.yaml" = ''
        general:
          appName: Pingvin Share X
          appUrl: https://share.mgrlab.dk
          secureCookies: "true"
        share:
          enableUserRecipients: "false"
        oauth:
          allowRegistration: "true"
          disablePassword: "false"
          oidc-enabled: "true"
          oidc-discoveryUri: https://oidc.mgrlab.dk/.well-known/openid-configuration
          oidc-signOut: "true"
          oidc-scope: openid email profile
          oidc-clientId: 35f539ab-a1e2-4f7a-8daf-fdf8ca60f8dd
          oidc-clientSecret: "{{ secrets.pingvin_share_oidc_client_secret }}"
        initUser:
          enabled: false
      '';
    };

    PersistentVolumeClaim."${app}-state" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "2Gi";
      };
    };

    PersistentVolumeClaim."${app}-images" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn";
        resources.requests.storage = "1Gi";
      };
    };

    PersistentVolumeClaim."${app}-uploads" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "local-path";
        resources.requests.storage = "20Gi";
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
                  TRUST_PROXY.value = "true";
                  PUID.value = "1000";
                  PGID.value = "1000";
                };

                ports = {
                  _namedlist = true;
                  http.containerPort = port;
                };

                volumeMounts = {
                  _namedlist = true;
                  state.mountPath = "/opt/app/backend/data";
                  uploads.mountPath = "/opt/app/backend/data/uploads";
                  images.mountPath = "/opt/app/frontend/public/img";
                  config = {
                    mountPath = "/opt/app/config.yaml";
                    subPath = "config.yaml";
                    readOnly = true;
                  };
                };
              };
            };

            volumes = {
              _namedlist = true;
              state.persistentVolumeClaim.claimName = "${app}-state";
              uploads.persistentVolumeClaim.claimName = "${app}-uploads";
              images.persistentVolumeClaim.claimName = "${app}-images";
              config.secret.secretName = "${app}-config";
            };
          };
        };
      };
    };
  };
}
