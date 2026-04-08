{ config, ... }:
let
  app = "immich";
  namespace = "immich";
  version = "v2.7.2";

  imageServer = "ghcr.io/immich-app/immich-server:${version}";
  imageML = "ghcr.io/immich-app/immich-machine-learning:${version}-cuda";
  imageRedis = "docker.io/valkey/valkey:9@sha256:3eeb09785cd61ec8e3be35f8804c8892080f3ca21934d628abc24ee4ed1698f6";
  imagePostgres = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";

  # Common Env Vars mapped from a typical Immich .env
  commonEnv = {
    _namedlist = true;
    DB_HOSTNAME.value = "${app}-postgres";
    DB_USERNAME.value = "postgres";
    DB_DATABASE_NAME.value = "immich";
    REDIS_HOSTNAME.value = "${app}-redis";
    # Ensure this secret is created in your cluster!
    DB_PASSWORD.valueFrom.secretKeyRef = {
      name = "immich-secrets";
      key = "DB_PASSWORD";
    };
  };
in
{
  kubernetes.resources.none.Namespace.${namespace} = { };
  kubernetes.resources.${namespace} = {
    Secret."${app}-secrets" = {
      metadata.labels = {
        "app.kubernetes.io/name" = app;
        "app.kubernetes.io/part-of" = app;
      };
      type = "Opaque";
      stringData = {
        DB_PASSWORD = "{{ secrets.immich_postgres_password }}";
      };
    };

    PersistentVolumeClaim."${app}-postgres-data" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "5Gi";
      };
    };

    PersistentVolumeClaim."${app}-library-data" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn";
        resources.requests.storage = "50Gi"; # Adjust based on your photo library size
      };
    };

    PersistentVolumeClaim."${app}-model-cache" = {
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn";
        resources.requests.storage = "10Gi";
      };
    };

    Service."${app}-redis" = {
      spec = {
        ports = {
          _namedlist = true;
          tcp-redis = {
            port = 6379;
            targetPort = 6379;
          };
        };
        selector.app = "${app}-redis";
      };
    };

    Deployment."${app}-redis" = {
      spec = {
        replicas = 1;
        selector.matchLabels.app = "${app}-redis";
        template = {
          metadata.labels.app = "${app}-redis";
          spec.containers = {
            _namedlist = true;
            redis = {
              image = imageRedis;
              ports = {
                _namedlist = true;
                tcp-redis.containerPort = 6379;
              };
            };
          };
        };
      };
    };

    Service."${app}-postgres" = {
      spec = {
        ports = {
          _namedlist = true;
          tcp-postgresql = {
            port = 5432;
            targetPort = 5432;
          };
        };
        selector.app = "${app}-postgres";
        clusterIP = "None"; # Headless service
      };
    };

    Deployment."${app}-postgres" = {
      spec = {
        replicas = 1;
        strategy.type = "Recreate"; # Mandatory for RWO volumes
        selector.matchLabels.app = "${app}-postgres";
        template = {
          metadata.labels.app = "${app}-postgres";
          spec = {
            containers = {
              _namedlist = true;
              postgres = {
                image = imagePostgres;
                env = {
                  _namedlist = true;
                  POSTGRES_USER.value = "postgres";
                  POSTGRES_DB.value = "immich";
                  POSTGRES_INITDB_ARGS.value = "--data-checksums";
                  POSTGRES_PASSWORD.valueFrom.secretKeyRef = {
                    name = "immich-secrets";
                    key = "DB_PASSWORD";
                  };
                };
                ports = {
                  _namedlist = true;
                  tcp-postgresql.containerPort = 5432;
                };
                volumeMounts = {
                  _namedlist = true;
                  pgdata.mountPath = "/var/lib/postgresql/data";
                  dshm.mountPath = "/dev/shm";
                };
              };
            };
            volumes = {
              _namedlist = true;
              pgdata.persistentVolumeClaim.claimName = "${app}-postgres-data";
              # Translates docker shm_size: 128mb
              dshm.emptyDir = {
                medium = "Memory";
                sizeLimit = "128Mi";
              };
            };
          };
        };
      };
    };

    # ==========================================
    # 4. Immich Machine Learning
    # ==========================================
    Service."${app}-machine-learning" = {
      spec = {
        ports = {
          _namedlist = true;
          http = {
            port = 3003;
            targetPort = 3003;
          };
        };
        selector.app = "${app}-machine-learning";
      };
    };

    Deployment."${app}-machine-learning" = {
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels.app = "${app}-machine-learning";
        template = {
          metadata.labels.app = "${app}-machine-learning";
          spec = {
            runtimeClassName = "nvidia";
            containers = {
              _namedlist = true;
              machine-learning = {
                image = imageML;
                resources.limits."nvidia.com/gpu" = 1;
                env = commonEnv;
                ports = {
                  _namedlist = true;
                  http.containerPort = 3003;
                };
                volumeMounts = {
                  _namedlist = true;
                  model-cache.mountPath = "/cache";
                };
              };
            };
            volumes = {
              _namedlist = true;
              model-cache.persistentVolumeClaim.claimName = "${app}-model-cache";
            };
          };
        };
      };
    };

    # ==========================================
    # 5. Immich Server (Main App)
    # ==========================================
    Service."${app}-server" = {
      spec = {
        ports = {
          _namedlist = true;
          http = {
            port = 2283;
            targetPort = 2283;
          };
        };
        selector.app = "${app}-server";
      };
    };

    Deployment."${app}-server" = {
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels.app = "${app}-server";
        template = {
          metadata.labels.app = "${app}-server";
          spec = {
            containers = {
              _namedlist = true;
              server = {
                image = imageServer;
                env = {
                  IMMICH_HELMET_FILE.value = "true";
                }
                // commonEnv;
                ports = {
                  _namedlist = true;
                  http.containerPort = 2283;
                };
                volumeMounts = {
                  _namedlist = true;
                  library.mountPath = "/data";
                  localtime = {
                    mountPath = "/etc/localtime";
                    readOnly = true;
                  };
                };
              };
            };
            volumes = {
              _namedlist = true;
              library.persistentVolumeClaim.claimName = "${app}-library-data";
              localtime.hostPath = {
                path = "/etc/localtime";
                type = "File";
              };
            };
          };
        };
      };
    };

  };
}
