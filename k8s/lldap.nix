{ lib, ... }:
let
  app = "lldap";
  image = "lldap/lldap:v0.6.3";
  ldapPort = 3890;
  httpPort = 17170;
in
{
  kubernetes.resources.media-stack = {
    Secret."${app}-secret" = {
      stringData = {
        LLDAP_JWT_SECRET = "{{ secrets.lldap_jwt_secret }}";
        LLDAP_KEY_SEED = "{{ secrets.lldap_key_seed }}";
        LLDAP_LDAP_USER_PASS = "{{ secrets.lldap_admin_password }}";
      };
    };

    PersistentVolumeClaim."${app}-data" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "1Gi";
      };
    };

    Service.${app} = {
      spec = {
        ports = lib.mkNamedList {
          ldap = {
            port = ldapPort;
            targetPort = ldapPort;
          };
          http = {
            port = httpPort;
            targetPort = httpPort;
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
                  LLDAP_DATABASE_URL.value = "sqlite:///data/users.db?mode=rwc";
                  LLDAP_FORCE_LDAP_USER_PASS_RESET.value = "always";
                  LLDAP_LDAP_BASE_DN.value = "dc=mgrlab,dc=dk";
                  LLDAP_JWT_SECRET.valueFrom.secretKeyRef = {
                    name = "${app}-secret";
                    key = "LLDAP_JWT_SECRET";
                  };
                  LLDAP_KEY_SEED.valueFrom.secretKeyRef = {
                    name = "${app}-secret";
                    key = "LLDAP_KEY_SEED";
                  };
                  LLDAP_LDAP_USER_PASS.valueFrom.secretKeyRef = {
                    name = "${app}-secret";
                    key = "LLDAP_LDAP_USER_PASS";
                  };
                };

                ports = lib.mkNamedList {
                  ldap.containerPort = ldapPort;
                  http.containerPort = httpPort;
                };

                volumeMounts = lib.mkNamedList {
                  data.mountPath = "/data";
                };
              };
            };

            volumes = lib.mkNamedList {
              data.persistentVolumeClaim.claimName = "${app}-data";
            };
          };
        };
      };
    };
  };
}
