_:
let
  app = "dawarich";
  namespace = app;
  appPort = 3000;

  dawarichVersion = "1.11.0";
  redisVersion = "7.4-alpine";
  postgisVersion = "17-3.5-alpine";

  dawarichImage = "freikin/dawarich:${dawarichVersion}";
  redisImage = "redis:${redisVersion}";
  postgisImage = "postgis/postgis:${postgisVersion}";

  commonLabels = {
    "app.kubernetes.io/name" = app;
    "app.kubernetes.io/instance" = app;
    "app.kubernetes.io/part-of" = app;
    "app.kubernetes.io/managed-by" = "easykubenix";
  };
  labelsFor = component: commonLabels // { "app.kubernetes.io/component" = component; };
  versionedLabelsFor =
    component: version: labelsFor component // { "app.kubernetes.io/version" = version; };
  selectorFor = component: {
    "app.kubernetes.io/name" = app;
    "app.kubernetes.io/instance" = app;
    "app.kubernetes.io/component" = component;
  };

  commonAppEnv = {
    _namedlist = true;
    RAILS_ENV.value = "production";
    REDIS_URL.value = "redis://${app}-redis:6379";
    DATABASE_HOST.value = "${app}-postgres";
    DATABASE_PORT.value = "5432";
    DATABASE_USERNAME.value = "postgres";
    DATABASE_NAME.value = "dawarich_development";
    APPLICATION_HOSTS.value = "localhost,::1,127.0.0.1,${app},${app}.${namespace}.svc.cluster.local,dawarich.mgrlab.dk";
    DOMAIN.value = "dawarich.mgrlab.dk";
    APPLICATION_PROTOCOL.value = "http";
    PROMETHEUS_EXPORTER_ENABLED.value = "false";
    RAILS_LOG_TO_STDOUT.value = "true";
    SELF_HOSTED.value = "true";
    STORE_GEODATA.value = "true";
    DATABASE_PASSWORD.valueFrom.secretKeyRef = {
      name = "${app}-secrets";
      key = "POSTGRES_PASSWORD";
    };
    SECRET_KEY_BASE.valueFrom.secretKeyRef = {
      name = "${app}-secrets";
      key = "SECRET_KEY_BASE";
    };
  };

  redisProbe = {
    exec.command = [
      "redis-cli"
      "--raw"
      "incr"
      "ping"
    ];
    periodSeconds = 10;
    timeoutSeconds = 10;
    failureThreshold = 5;
  };
  postgresProbe = {
    exec.command = [
      "sh"
      "-c"
      "pg_isready -U postgres -d dawarich_development"
    ];
    periodSeconds = 10;
    timeoutSeconds = 10;
    failureThreshold = 5;
  };
  webProbe = {
    exec.command = [
      "sh"
      "-c"
      "wget -qO - http://127.0.0.1:${toString appPort}/api/v1/health | grep -Eq '\"status\"[[:space:]]*:[[:space:]]*\"ok\"'"
    ];
    periodSeconds = 10;
    timeoutSeconds = 10;
    failureThreshold = 30;
  };
  sidekiqProbe = {
    exec.command = [
      "sh"
      "-c"
      "pgrep -f sidekiq"
    ];
    periodSeconds = 10;
    timeoutSeconds = 10;
    failureThreshold = 30;
  };
in
{
  kubernetes.resources.none.Namespace.${namespace}.metadata.labels = commonLabels;

  kubernetes.resources.${namespace} = {
    Secret."${app}-secrets" = {
      metadata.labels = labelsFor "configuration";
      type = "Opaque";
      stringData = {
        POSTGRES_PASSWORD = "{{ secrets.dawarich_postgres_password }}";
        SECRET_KEY_BASE = "{{ secrets.dawarich_secret_key_base }}";
      };
    };

    PersistentVolumeClaim."${app}-postgres-data" = {
      metadata.labels = labelsFor "database";
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "20Gi";
      };
    };
    PersistentVolumeClaim."${app}-shared" = {
      metadata.labels = labelsFor "shared-storage";
      spec = {
        accessModes = [ "ReadWriteMany" ];
        storageClassName = "longhorn";
        resources.requests.storage = "5Gi";
      };
    };
    PersistentVolumeClaim."${app}-public" = {
      metadata.labels = labelsFor "web-storage";
      spec = {
        accessModes = [ "ReadWriteMany" ];
        storageClassName = "longhorn";
        resources.requests.storage = "1Gi";
      };
    };
    PersistentVolumeClaim."${app}-watched" = {
      metadata.labels = labelsFor "imports";
      spec = {
        accessModes = [ "ReadWriteMany" ];
        storageClassName = "longhorn";
        resources.requests.storage = "10Gi";
      };
    };
    PersistentVolumeClaim."${app}-storage" = {
      metadata.labels = labelsFor "application-storage";
      spec = {
        accessModes = [ "ReadWriteMany" ];
        storageClassName = "longhorn";
        resources.requests.storage = "50Gi";
      };
    };

    Service."${app}-redis" = {
      metadata.labels = versionedLabelsFor "cache" redisVersion;
      spec = {
        selector = selectorFor "cache";
        ports = {
          _namedlist = true;
          redis = {
            port = 6379;
            targetPort = 6379;
          };
        };
      };
    };
    Service."${app}-postgres" = {
      metadata.labels = versionedLabelsFor "database" postgisVersion;
      spec = {
        selector = selectorFor "database";
        ports = {
          _namedlist = true;
          postgres = {
            port = 5432;
            targetPort = 5432;
          };
        };
      };
    };
    Service.${app} = {
      metadata.labels = versionedLabelsFor "web" dawarichVersion;
      spec = {
        selector = selectorFor "web";
        ports = {
          _namedlist = true;
          http = {
            port = appPort;
            targetPort = appPort;
          };
        };
      };
    };

    Deployment."${app}-redis" = {
      metadata.labels = versionedLabelsFor "cache" redisVersion;
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = selectorFor "cache";
        template = {
          metadata.labels = versionedLabelsFor "cache" redisVersion;
          spec.containers = {
            _namedlist = true;
            redis = {
              image = redisImage;
              args = [
                "redis-server"
                "--save"
                "900"
                "1"
                "--save"
                "300"
                "10"
                "--appendonly"
                "no"
              ];
              ports = {
                _namedlist = true;
                redis.containerPort = 6379;
              };
              startupProbe = redisProbe // {
                initialDelaySeconds = 30;
              };
              readinessProbe = redisProbe;
              livenessProbe = redisProbe;
              volumeMounts = {
                _namedlist = true;
                shared.mountPath = "/data";
              };
            };
          };
          spec.volumes = {
            _namedlist = true;
            shared.persistentVolumeClaim.claimName = "${app}-shared";
          };
        };
      };
    };

    Deployment."${app}-postgres" = {
      metadata.labels = versionedLabelsFor "database" postgisVersion;
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = selectorFor "database";
        template = {
          metadata.labels = versionedLabelsFor "database" postgisVersion;
          spec = {
            containers = {
              _namedlist = true;
              postgres = {
                image = postgisImage;
                env = {
                  _namedlist = true;
                  POSTGRES_USER.value = "postgres";
                  POSTGRES_DB.value = "dawarich_development";
                  POSTGRES_PASSWORD.valueFrom.secretKeyRef = {
                    name = "${app}-secrets";
                    key = "POSTGRES_PASSWORD";
                  };
                };
                ports = {
                  _namedlist = true;
                  postgres.containerPort = 5432;
                };
                startupProbe = postgresProbe // {
                  initialDelaySeconds = 30;
                };
                readinessProbe = postgresProbe;
                livenessProbe = postgresProbe;
                volumeMounts = {
                  _namedlist = true;
                  data.mountPath = "/var/lib/postgresql/data";
                  shared.mountPath = "/var/shared";
                  shm.mountPath = "/dev/shm";
                };
              };
            };
            volumes = {
              _namedlist = true;
              data.persistentVolumeClaim.claimName = "${app}-postgres-data";
              shared.persistentVolumeClaim.claimName = "${app}-shared";
              shm.emptyDir = {
                medium = "Memory";
                sizeLimit = "1Gi";
              };
            };
          };
        };
      };
    };

    Deployment.${app} = {
      metadata.labels = versionedLabelsFor "web" dawarichVersion;
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = selectorFor "web";
        template = {
          metadata.labels = versionedLabelsFor "web" dawarichVersion;
          spec = {
            # The web container mounts the RWO database claim for Dawarich's backup tooling.
            affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution = [
              {
                labelSelector.matchLabels = selectorFor "database";
                topologyKey = "kubernetes.io/hostname";
              }
            ];
            containers = {
              _namedlist = true;
              ${app} = {
                image = dawarichImage;
                stdin = true;
                tty = true;
                command = [ "web-entrypoint.sh" ];
                args = [
                  "bin/rails"
                  "server"
                  "-p"
                  (toString appPort)
                  "-b"
                  "::"
                ];
                env = commonAppEnv // {
                  TIME_ZONE.value = "Europe/London";
                  WEB_CONCURRENCY.value = "1";
                  OIDC_CLIENT_ID.value = "be2c46bd-eddb-46cb-aac9-1812006d9697";
                  OIDC_CLIENT_SECRET.value = "z76kOIx9FaSmD7eKyPXJSb8yf1SOvz76";
                  OIDC_ISSUER.value = "https://oidc.mgrlab.dk";
                  OIDC_REDIRECT_URI.value = "https://dawarich.mgrlab.dk/users/auth/openid_connect/callback";
                  OIDC_PROVIDER_NAME.value = "Pocket ID";
                  OIDC_AUTO_REGISTER.value = "true";
                  OIDC_PKCE_ENABLED.value = "true";
                  ALLOW_EMAIL_PASSWORD_REGISTRATION.value = "false";
                  ALLOW_EMAIL_PASSWORD_LOGIN.value = "false";
                };
                resources.limits = {
                  cpu = "500m";
                  memory = "4Gi";
                };
                ports = {
                  _namedlist = true;
                  http.containerPort = appPort;
                };
                startupProbe = webProbe // {
                  initialDelaySeconds = 30;
                };
                readinessProbe = webProbe;
                livenessProbe = webProbe;
                volumeMounts = {
                  _namedlist = true;
                  public.mountPath = "/var/app/public";
                  watched.mountPath = "/var/app/tmp/imports/watched";
                  storage.mountPath = "/var/app/storage";
                  database-backups.mountPath = "/dawarich_db_data";
                };
              };
            };
            volumes = {
              _namedlist = true;
              public.persistentVolumeClaim.claimName = "${app}-public";
              watched.persistentVolumeClaim.claimName = "${app}-watched";
              storage.persistentVolumeClaim.claimName = "${app}-storage";
              database-backups.persistentVolumeClaim.claimName = "${app}-postgres-data";
            };
          };
        };
      };
    };

    Deployment."${app}-sidekiq" = {
      metadata.labels = versionedLabelsFor "worker" dawarichVersion;
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = selectorFor "worker";
        template = {
          metadata.labels = versionedLabelsFor "worker" dawarichVersion;
          spec = {
            containers = {
              _namedlist = true;
              sidekiq = {
                image = dawarichImage;
                stdin = true;
                tty = true;
                command = [ "sidekiq-entrypoint.sh" ];
                args = [ "sidekiq" ];
                env = commonAppEnv // {
                  BACKGROUND_PROCESSING_CONCURRENCY.value = "3";
                };
                startupProbe = sidekiqProbe // {
                  initialDelaySeconds = 30;
                };
                readinessProbe = sidekiqProbe;
                livenessProbe = sidekiqProbe;
                volumeMounts = {
                  _namedlist = true;
                  public.mountPath = "/var/app/public";
                  watched.mountPath = "/var/app/tmp/imports/watched";
                  storage.mountPath = "/var/app/storage";
                };
              };
            };
            volumes = {
              _namedlist = true;
              public.persistentVolumeClaim.claimName = "${app}-public";
              watched.persistentVolumeClaim.claimName = "${app}-watched";
              storage.persistentVolumeClaim.claimName = "${app}-storage";
            };
          };
        };
      };
    };
  };
}
