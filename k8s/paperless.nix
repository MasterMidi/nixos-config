_:
let
  app = "paperless";
  namespace = app;
  hostname = "paperless.mgrlab.dk";
  webPort = 8000;

  versions = {
    broker = "8";
    database = "17";
    gotenberg = "8.20";
    paperless = "2.20";
    tika = "latest";
  };

  images = {
    broker = "docker.io/library/redis:${versions.broker}";
    database = "docker.io/library/postgres:${versions.database}";
    gotenberg = "docker.io/gotenberg/gotenberg:${versions.gotenberg}";
    paperless = "ghcr.io/paperless-ngx/paperless-ngx:${versions.paperless}";
    tika = "docker.io/apache/tika:${versions.tika}";
  };

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

  socialAccountProviders = builtins.toJSON {
    openid_connect = {
      SCOPE = [
        "openid"
        "profile"
        "email"
      ];
      OAUTH_PKCE_ENABLED = true;
      APPS = [
        {
          provider_id = "pocket-id";
          name = "Pocket ID";
          client_id = "4e5847bf-8fb6-4d83-8ed0-bad787994513";
          secret = "{{ secrets.paperless_pocketid_client_secret }}";
          settings = {
            server_url = "https://oidc.mgrlab.dk";
            token_auth_method = "client_secret_post";
          };
        }
      ];
    };
  };

  redisProbe = {
    exec.command = [
      "redis-cli"
      "ping"
    ];
    periodSeconds = 10;
    timeoutSeconds = 5;
    failureThreshold = 5;
  };
  postgresProbe = {
    exec.command = [
      "pg_isready"
      "-U"
      "paperless"
      "-d"
      "paperless"
    ];
    periodSeconds = 10;
    timeoutSeconds = 5;
    failureThreshold = 5;
  };
in
{
  kubernetes.resources.none.Namespace.${namespace}.metadata.labels = commonLabels;

  kubernetes.resources.${namespace} = {
    Secret."${app}-secrets" = {
      metadata.labels = labelsFor "configuration";
      type = "Opaque";
      stringData = {
        PAPERLESS_SOCIALACCOUNT_PROVIDERS = socialAccountProviders;
        PAPERLESS_SECRET_KEY = "{{ secrets.paperless_secret_key }}";
        POSTGRES_PASSWORD = "{{ secrets.paperless_postgres_password }}";
      };
    };

    PersistentVolumeClaim."${app}-broker-data" = {
      metadata.labels = labelsFor "cache";
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "1Gi";
      };
    };
    PersistentVolumeClaim."${app}-database-data" = {
      metadata.labels = labelsFor "database";
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "10Gi";
      };
    };
    PersistentVolumeClaim."${app}-data" = {
      metadata.labels = labelsFor "application-data";
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "5Gi";
      };
    };
    PersistentVolumeClaim."${app}-media" = {
      metadata.labels = labelsFor "documents";
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "longhorn";
        resources.requests.storage = "50Gi";
      };
    };
    PersistentVolumeClaim."${app}-export" = {
      metadata.labels = labelsFor "exports";
      spec = {
        accessModes = [ "ReadWriteMany" ];
        storageClassName = "longhorn";
        resources.requests.storage = "10Gi";
      };
    };
    PersistentVolumeClaim."${app}-consume" = {
      metadata.labels = labelsFor "imports";
      spec = {
        accessModes = [ "ReadWriteMany" ];
        storageClassName = "longhorn";
        resources.requests.storage = "10Gi";
      };
    };

    Service."${app}-broker" = {
      metadata.labels = versionedLabelsFor "cache" versions.broker;
      spec = {
        clusterIP = "None";
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
    Service."${app}-database" = {
      metadata.labels = versionedLabelsFor "database" versions.database;
      spec = {
        clusterIP = "None";
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
    Service."${app}-gotenberg" = {
      metadata.labels = versionedLabelsFor "document-converter" versions.gotenberg;
      spec = {
        selector = selectorFor "document-converter";
        ports = {
          _namedlist = true;
          http = {
            port = 3000;
            targetPort = 3000;
          };
        };
      };
    };
    Service."${app}-tika" = {
      metadata.labels = versionedLabelsFor "document-parser" versions.tika;
      spec = {
        selector = selectorFor "document-parser";
        ports = {
          _namedlist = true;
          http = {
            port = 9998;
            targetPort = 9998;
          };
        };
      };
    };
    Service.${app} = {
      metadata.labels = versionedLabelsFor "web" versions.paperless;
      spec = {
        selector = selectorFor "web";
        ports = {
          _namedlist = true;
          http = {
            port = webPort;
            targetPort = webPort;
          };
        };
      };
    };

    StatefulSet."${app}-broker" = {
      metadata.labels = versionedLabelsFor "cache" versions.broker;
      spec = {
        replicas = 1;
        serviceName = "${app}-broker";
        selector.matchLabels = selectorFor "cache";
        template = {
          metadata.labels = versionedLabelsFor "cache" versions.broker;
          spec = {
            automountServiceAccountToken = false;
            terminationGracePeriodSeconds = 30;
            containers = {
              _namedlist = true;
              redis = {
                image = images.broker;
                resources = {
                  requests = {
                    cpu = "25m";
                    memory = "64Mi";
                  };
                  limits.memory = "256Mi";
                };
                ports = {
                  _namedlist = true;
                  redis.containerPort = 6379;
                };
                startupProbe = redisProbe // {
                  failureThreshold = 30;
                };
                readinessProbe = redisProbe;
                livenessProbe = redisProbe;
                volumeMounts = {
                  _namedlist = true;
                  data.mountPath = "/data";
                };
              };
            };
            volumes = {
              _namedlist = true;
              data.persistentVolumeClaim.claimName = "${app}-broker-data";
            };
          };
        };
      };
    };

    StatefulSet."${app}-database" = {
      metadata.labels = versionedLabelsFor "database" versions.database;
      spec = {
        replicas = 1;
        serviceName = "${app}-database";
        selector.matchLabels = selectorFor "database";
        template = {
          metadata.labels = versionedLabelsFor "database" versions.database;
          spec = {
            automountServiceAccountToken = false;
            terminationGracePeriodSeconds = 60;
            containers = {
              _namedlist = true;
              postgres = {
                image = images.database;
                resources = {
                  requests = {
                    cpu = "100m";
                    memory = "256Mi";
                  };
                  limits.memory = "1Gi";
                };
                env = {
                  _namedlist = true;
                  POSTGRES_DB.value = "paperless";
                  POSTGRES_USER.value = "paperless";
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
                  failureThreshold = 30;
                };
                readinessProbe = postgresProbe;
                livenessProbe = postgresProbe;
                volumeMounts = {
                  _namedlist = true;
                  data.mountPath = "/var/lib/postgresql/data";
                  shm.mountPath = "/dev/shm";
                };
              };
            };
            volumes = {
              _namedlist = true;
              data.persistentVolumeClaim.claimName = "${app}-database-data";
              shm.emptyDir = {
                medium = "Memory";
                sizeLimit = "256Mi";
              };
            };
          };
        };
      };
    };

    Deployment."${app}-gotenberg" = {
      metadata.labels = versionedLabelsFor "document-converter" versions.gotenberg;
      spec = {
        replicas = 1;
        selector.matchLabels = selectorFor "document-converter";
        template = {
          metadata.labels = versionedLabelsFor "document-converter" versions.gotenberg;
          spec = {
            automountServiceAccountToken = false;
            containers = {
              _namedlist = true;
              gotenberg = {
                image = images.gotenberg;
                args = [
                  "gotenberg"
                  "--chromium-disable-javascript=true"
                  "--chromium-allow-list=file:///tmp/.*"
                ];
                resources = {
                  requests = {
                    cpu = "100m";
                    memory = "256Mi";
                  };
                  limits.memory = "1Gi";
                };
                ports = {
                  _namedlist = true;
                  http.containerPort = 3000;
                };
                startupProbe = {
                  httpGet = {
                    path = "/health";
                    port = 3000;
                  };
                  periodSeconds = 10;
                  failureThreshold = 30;
                };
                readinessProbe = {
                  httpGet = {
                    path = "/health";
                    port = 3000;
                  };
                  periodSeconds = 10;
                };
                livenessProbe = {
                  httpGet = {
                    path = "/health";
                    port = 3000;
                  };
                  periodSeconds = 30;
                };
              };
            };
          };
        };
      };
    };

    Deployment."${app}-tika" = {
      metadata.labels = versionedLabelsFor "document-parser" versions.tika;
      spec = {
        replicas = 1;
        selector.matchLabels = selectorFor "document-parser";
        template = {
          metadata.labels = versionedLabelsFor "document-parser" versions.tika;
          spec = {
            automountServiceAccountToken = false;
            containers = {
              _namedlist = true;
              tika = {
                image = images.tika;
                resources = {
                  requests = {
                    cpu = "100m";
                    memory = "256Mi";
                  };
                  limits.memory = "1Gi";
                };
                ports = {
                  _namedlist = true;
                  http.containerPort = 9998;
                };
                startupProbe = {
                  tcpSocket.port = 9998;
                  periodSeconds = 10;
                  failureThreshold = 30;
                };
                readinessProbe = {
                  tcpSocket.port = 9998;
                  periodSeconds = 10;
                };
                livenessProbe = {
                  tcpSocket.port = 9998;
                  periodSeconds = 30;
                };
              };
            };
          };
        };
      };
    };

    Deployment.${app} = {
      metadata.labels = versionedLabelsFor "web" versions.paperless;
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = selectorFor "web";
        template = {
          metadata.labels = versionedLabelsFor "web" versions.paperless;
          spec = {
            # automountServiceAccountToken = false;
            # terminationGracePeriodSeconds = 60;
            containers = {
              _namedlist = true;
              paperless = {
                image = images.paperless;
                resources = {
                  requests = {
                    cpu = "250m";
                    memory = "512Mi";
                  };
                  limits.memory = "2Gi";
                };
                env = {
                  _namedlist = true;
                  PAPERLESS_PORT.value = toString webPort;
                  PAPERLESS_URL.value = "https://${hostname}";
                  PAPERLESS_REDIS.value = "redis://${app}-broker:6379";
                  PAPERLESS_DBHOST.value = "${app}-database";
                  PAPERLESS_DBPASS.valueFrom.secretKeyRef = {
                    name = "${app}-secrets";
                    key = "POSTGRES_PASSWORD";
                  };
                  PAPERLESS_TIKA_ENABLED.value = "1";
                  PAPERLESS_TIKA_GOTENBERG_ENDPOINT.value = "http://${app}-gotenberg:3000";
                  PAPERLESS_TIKA_ENDPOINT.value = "http://${app}-tika:9998";
                  PAPERLESS_OCR_LANGUAGES.value = "dan eng";
                  PAPERLESS_APPS.value = "allauth.socialaccount.providers.openid_connect";
                  PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS.value = "True";
                  PAPERLESS_SOCIAL_AUTO_SIGNUP.value = "True";
                  PAPERLESS_SOCIALACCOUNT_PROVIDERS.valueFrom.secretKeyRef = {
                    name = "${app}-secrets";
                    key = "PAPERLESS_SOCIALACCOUNT_PROVIDERS";
                  };
                  PAPERLESS_SECRET_KEY.valueFrom.secretKeyRef = {
                    name = "${app}-secrets";
                    key = "PAPERLESS_SECRET_KEY";
                  };
                };
                # startupProbe = {
                #   httpGet = {
                #     path = "/";
                #     port = webPort;
                #   };
                #   periodSeconds = 10;
                #   timeoutSeconds = 5;
                #   failureThreshold = 60;
                # };
                # readinessProbe = {
                #   httpGet = {
                #     path = "/";
                #     port = webPort;
                #   };
                #   periodSeconds = 10;
                #   timeoutSeconds = 5;
                # };
                # livenessProbe = {
                #   httpGet = {
                #     path = "/";
                #     port = webPort;
                #   };
                #   periodSeconds = 30;
                #   timeoutSeconds = 5;
                #   failureThreshold = 5;
                # };
                volumeMounts = {
                  _namedlist = true;
                  data.mountPath = "/usr/src/paperless/data";
                  media.mountPath = "/usr/src/paperless/media";
                  export.mountPath = "/usr/src/paperless/export";
                  consume.mountPath = "/usr/src/paperless/consume";
                };
              };
            };
            volumes = {
              _namedlist = true;
              data.persistentVolumeClaim.claimName = "${app}-data";
              media.persistentVolumeClaim.claimName = "${app}-media";
              export.persistentVolumeClaim.claimName = "${app}-export";
              consume.persistentVolumeClaim.claimName = "${app}-consume";
            };
          };
        };
      };
    };

    # Ingress.${app} = {
    #   metadata = {
    #     labels = versionedLabelsFor "web" versions.paperless;
    #     annotations."traefik.ingress.kubernetes.io/router.entrypoints" = "web";
    #   };
    #   spec = {
    #     ingressClassName = "traefik";
    #     rules = [
    #       {
    #         host = hostname;
    #         http.paths = [
    #           {
    #             path = "/";
    #             pathType = "Prefix";
    #             backend.service = {
    #               name = app;
    #               port.name = "http";
    #             };
    #           }
    #         ];
    #       }
    #     ];
    #   };
    # };
  };
}
