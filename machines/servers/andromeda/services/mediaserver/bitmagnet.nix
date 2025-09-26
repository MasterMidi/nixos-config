{
  config,
  lib,
  ...
}: {
  services.cloudflared.tunnels.andromeda.ingress = {
    "bitmagnet.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    networks.bitmagnet = {
      subnets = ["10.89.100.0/24"];
      gateways = ["10.89.100.1"];
    };
    containers = rec {
      bitmagnetgluetun = rec {
        image = "qmcgaw/gluetun:latest";
        networking = {
          networks = ["default" "bitmagnet"];
          aliases = ["bitmagnet"];
          ports = let
            dht-port = lib.toInt bitmagnet.environment.DHT_SERVER_PORT;
          in {
            webui = {
              host = 3333;
              internal = 3333;
            };
            crawler-tcp = {
              host = dht-port;
              internal = dht-port;
              protocol = "tcp";
            };
            crawler-udp = {
              host = dht-port;
              internal = dht-port;
              protocol = "udp";
            };
          };
        };
        environment = {
          FIREWALL_VPN_INPUT_PORTS = bitmagnet.environment.DHT_SERVER_PORT;

          VPN_SERVICE_PROVIDER = "airvpn";
          VPN_TYPE = "wireguard";
          WIREGUARD_ADDRESSES = "10.142.244.184/32,fd7d:76ee:e68f:a993:77f5:2a70:242b:6a1a/128";
          SERVER_REGIONS = "Europe";
        };
        secrets.env = {
          WIREGUARD_PRIVATE_KEY.path = config.sops.secrets.AIRVPN_WIREGUARD_PRIVATE_KEY.path;
          WIREGUARD_PRESHARED_KEY.path = config.sops.secrets.AIRVPN_WIREGUARD_PRESHARED_KEY.path;
        };
        capabilities = ["NET_ADMIN"];
        devices = ["/dev/net/tun"];
        extraOptions = [
          "--add-host=${builtins.head bitmagnet-postgres.networking.aliases}:10.89.100.5"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.http.routers.bitmagnet.rule=Host(`bitmagnet.mgrlab.dk`)"
          "traefik.http.routers.bitmagnet.entrypoints=local"
          "traefik.http.services.bitmagnet.loadbalancer.server.port=${toString networking.ports.webui.internal}"
          "traefik.http.services.bitmagnet.loadbalancer.passHostHeader=true"
        ];
      };

      bitmagnet = rec {
        image = "ghcr.io/bitmagnet-io/bitmagnet:v0.10.0";
        networking = {
          networks = ["container:bitmagnetgluetun"];
          # aliases = ["bitmagnet"];
          # ports = {
          #   # TODO make this possible
          #   # crawler = {
          #   #   host = 3334;
          #   #   internal = 3334;
          #   #   protocol = ["tcp" "udp"];
          #   # };
          # };
        };
        environment = {
          POSTGRES_HOST = builtins.head bitmagnet-postgres.networking.aliases;
          POSTGRES_NAME = bitmagnet-postgres.environment.POSTGRES_DB;
          POSTGRES_USER = bitmagnet-postgres.environment.PGUSER;

          HTTP_SERVER_CORS_ALLOWED_ORIGINS = "bitmagnet.mgrlab.dk,andromeda";
          PROCESSOR_CONCURRENCY = "3";
          DHT_SERVER_PORT = "54964";
        };
        secrets.env = {
          POSTGRES_PASSWORD.path = bitmagnet-postgres.secrets.env.POSTGRES_PASSWORD.path;
          TMDB_API_KEY.path = config.sops.secrets.TMDB_API_KEY.path;
        };
        commands = [
          "worker"
          "run"
          "--keys=http_server"
          "--keys=queue_server"
          # disable the next line to run without DHT crawler
          "--keys=dht_crawler"
        ];
        dependsOn = ["bitmagnet-postgres" "bitmagnetgluetun"];
      };

      bitmagnet-postgres = {
        image = "postgres:16-alpine";
        networking = {
          networks = ["bitmagnet:ip=10.89.100.5"];
          aliases = ["bitmagnet-postgres"];
        };
        volumes = [
          "/mnt/ssd/services/bitmagnet/data:/var/lib/postgresql/data:rw"
        ];
        environment = {
          POSTGRES_DB = "bitmagnet";
          PGUSER = "postgres";
        };
        secrets.env = {
          POSTGRES_PASSWORD.path = config.sops.secrets.BITMAGNET_POSTGRES_PASSWORD.path;
        };
        extraOptions = ["--shm-size=1g"];
      };
    };
  };
}
