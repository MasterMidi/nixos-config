{ ... }:
let
  app = "bitmagnet";
  webuiPort = 3333;
  dhtPort = 54438;
  postgresDb = "bitmagnet";
  postgresUser = "postgres";
in
{
  kubernetes.resources.media-stack = {
    Secret."${app}-secret" = {
      stringData = {
        AIRVPN_WIREGUARD_PRIVATE_KEY = "{{ secrets.airvpn_wireguard_private_key }}";
        AIRVPN_WIREGUARD_PRESHARED_KEY = "{{ secrets.airvpn_wireguard_preshared_key }}";
        POSTGRES_PASSWORD = "{{ secrets.bitmagnet_postgres_password }}";
        TMDB_API_KEY = "{{ secrets.tmdb_api_key }}";
      };
    };
    Service.${app} = {
      spec = {
        selector = { inherit app; };
        ports = {
          _namedlist = true;
          webui = {
            port = webuiPort;
            targetPort = webuiPort;
          };
          crawler-tcp = {
            port = dhtPort;
            targetPort = dhtPort;
            protocol = "TCP";
          };
          crawler-udp = {
            port = dhtPort;
            targetPort = dhtPort;
            protocol = "UDP";
          };
        };
      };
    };

    Service."${app}-postgres" = {
      spec = {
        selector = {
          app = "${app}-postgres";
        };
        ports = {
          _namedlist = true;
          postgres = {
            port = 5432;
            targetPort = 5432;
          };
        };
      };
    };

    # --- 2. Database Deployment ---

    Deployment."${app}-postgres" = {
      spec = {
        replicas = 1;
        strategy.type = "Recreate"; # Important for hostPath/PVCs
        selector.matchLabels = {
          app = "${app}-postgres";
        };
        template = {
          metadata.labels = {
            app = "${app}-postgres";
          };
          spec = {
            containers = {
              _namedlist = true;
              postgres = {
                image = "postgres:16-alpine";
                env = {
                  _namedlist = true;
                  POSTGRES_DB.value = postgresDb;
                  PGUSER.value = postgresUser;
                  POSTGRES_PASSWORD.valueFrom.secretKeyRef = {
                    name = "bitmagnet-secret";
                    key = "POSTGRES_PASSWORD";
                  };
                };
                ports = {
                  _namedlist = true;
                  postgres.containerPort = 5432;
                };
                volumeMounts = {
                  _namedlist = true;
                  data.mountPath = "/var/lib/postgresql/data";
                  shm.mountPath = "/dev/shm";
                };
              };
            };
            volumes = {
              _namedlist = true;
              data.hostPath = {
                path = "/mnt/ssd/services/bitmagnet/data";
                type = "DirectoryOrCreate";
              };
              shm.emptyDir = {
                medium = "Memory";
                sizeLimit = "1Gi";
              };
            };
          };
        };
      };
    };

    # --- 3. App + VPN Sidecar Deployment ---

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

              # Container A: The VPN Sidecar
              gluetun = {
                image = "qmcgaw/gluetun:latest";
                securityContext = {
                  capabilities.add = [ "NET_ADMIN" ];
                };
                env = {
                  _namedlist = true;
                  FIREWALL_VPN_INPUT_PORTS.value = toString dhtPort;
                  VPN_SERVICE_PROVIDER.value = "airvpn";
                  VPN_TYPE.value = "wireguard";
                  WIREGUARD_ADDRESSES.value = "10.142.244.184/32,fd7d:76ee:e68f:a993:77f5:2a70:242b:6a1a/128";
                  SERVER_REGIONS.value = "Europe";
                  DNS_KEEP_NAMESERVER.value = "on";
                  FIREWALL_OUTBOUND_SUBNETS.value = "10.42.0.0/16,10.43.0.0/16,192.168.1.0/24";
                  WIREGUARD_PRIVATE_KEY.valueFrom.secretKeyRef = {
                    name = "bitmagnet-secret"; # FIXED
                    key = "AIRVPN_WIREGUARD_PRIVATE_KEY"; # FIXED
                  };
                  WIREGUARD_PRESHARED_KEY.valueFrom.secretKeyRef = {
                    name = "bitmagnet-secret"; # FIXED
                    key = "AIRVPN_WIREGUARD_PRESHARED_KEY"; # FIXED
                  };
                };
                ports = {
                  _namedlist = true;
                  webui.containerPort = webuiPort;
                  dht-tcp = {
                    containerPort = dhtPort;
                    protocol = "TCP";
                  };
                  dht-udp = {
                    containerPort = dhtPort;
                    protocol = "UDP";
                  };
                };
                volumeMounts = {
                  _namedlist = true;
                  tun.mountPath = "/dev/net/tun";
                };
              };

              # Container B: The Main App
              bitmagnet = {
                image = "ghcr.io/bitmagnet-io/bitmagnet:v0.10.0";
                args = [
                  "worker"
                  "run"
                  "--keys=http_server"
                  "--keys=queue_server"
                  "--keys=dht_crawler"
                ];
                env = {
                  _namedlist = true;
                  POSTGRES_HOST.value = "${app}-postgres.media-stack.svc.cluster.local";
                  POSTGRES_NAME.value = postgresDb;
                  POSTGRES_USER.value = postgresUser;
                  POSTGRES_PORT.value = "5432";
                  POSTGRES_PASSWORD.valueFrom.secretKeyRef = {
                    name = "bitmagnet-secret";
                    key = "POSTGRES_PASSWORD";
                  };
                  TMDB_API_KEY.valueFrom.secretKeyRef = {
                    name = "bitmagnet-secret";
                    key = "TMDB_API_KEY";
                  };
                  HTTP_SERVER_CORS_ALLOWED_ORIGINS.value = "bitmagnet.mgrlab.dk";
                  PROCESSOR_CONCURRENCY.value = "3";
                  DHT_SERVER_PORT.value = toString dhtPort;
                };
              };
            };
            volumes = {
              _namedlist = true;
              tun.hostPath = {
                path = "/dev/net/tun";
                type = "CharDevice";
              };
            };
          };
        };
      };
    };
  };
}
