{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "gotify.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    networks.hoarder = {};
    containers = {
      gotify = rec {
        image = "ghcr.io/gotify/server";
        networking = {
          networks = ["default"];
          aliases = ["gotify"];
          ports = {
            webui = {
              host = 5656;
              internal = 80;
            };
          };
        };
        environment = {
            TZ= config.time.timeZone;

            GOTIFY_SERVER_PORT="80";
            GOTIFY_SERVER_KEEPALIVEPERIODSECONDS="0";
            # GOTIFY_SERVER_LISTENADDR=
            GOTIFY_SERVER_SSL_ENABLED="false";
            # GOTIFY_SERVER_SSL_REDIRECTTOHTTPS=true
            # GOTIFY_SERVER_SSL_LISTENADDR=
            # GOTIFY_SERVER_SSL_PORT=443
            # GOTIFY_SERVER_SSL_CERTFILE=
            # GOTIFY_SERVER_SSL_CERTKEY=
            # GOTIFY_SERVER_SSL_LETSENCRYPT_ENABLED=false
            # GOTIFY_SERVER_SSL_LETSENCRYPT_ACCEPTTOS=false
            # GOTIFY_SERVER_SSL_LETSENCRYPT_CACHE=certs
            # GOTIFY_SERVER_SSL_LETSENCRYPT_HOSTS=[mydomain.tld, myotherdomain.tld]
            # GOTIFY_SERVER_RESPONSEHEADERS={X-Custom-Header: "custom value", x-other: value}
            # GOTIFY_SERVER_TRUSTEDPROXIES=[127.0.0.1,192.168.178.2/24]
            # GOTIFY_SERVER_CORS_ALLOWORIGINS=[.+\.example\.com, otherdomain\.com]
            # GOTIFY_SERVER_CORS_ALLOWMETHODS=[GET, POST]
            # GOTIFY_SERVER_CORS_ALLOWHEADERS=[X-Gotify-Key, Authorization]
            # GOTIFY_SERVER_STREAM_ALLOWEDORIGINS=[.+.example\.com, otherdomain\.com]
            GOTIFY_SERVER_STREAM_PINGPERIODSECONDS="45";
            GOTIFY_DATABASE_DIALECT="sqlite3";
            GOTIFY_DATABASE_CONNECTION="data/gotify.db";
            GOTIFY_DEFAULTUSER_NAME="admin";
            GOTIFY_DEFAULTUSER_PASS="admin";
            GOTIFY_PASSSTRENGTH="10";
            GOTIFY_UPLOADEDIMAGESDIR="data/images";
            GOTIFY_PLUGINSDIR="data/plugins";
            GOTIFY_REGISTRATION="true";
        };
        volumes = [
          "/mnt/ssd/services/gotify/data:/app/data"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.http.routers.gotify.rule=Host(`gotify.mgrlab.dk`)"
          "traefik.http.routers.gotify.entrypoints=local"
          "traefik.http.routers.gotify.service=gotify"
          "traefik.http.services.gotify.loadbalancer.server.port=${toString networking.ports.webui.internal}"

          # Monitoring
        #   "kuma.gotify.http.name=gotify"
        #   "kuma.gotify.http.url=https://gotify.mgrlab.dk/health"
        ];
      };
      apprise = {
        image = "ghcr.io/caronc/apprise:latest";
        networking = {
          networks = ["default"];
          aliases = ["apprise"];
          ports = {
            webui = {
              host = 8000;
              internal = 8000;
            };
          };
        };
        environment = {
          APPRISE_STATEFUL_MODE="simple";
        };
        volumes = [
          # "/mnt/ssd/services/apprise/webapp:/opt/apprise/webapp:ro"
          "/mnt/ssd/services/apprise/config:/config:rw"
          "/mnt/ssd/services/apprise/attach:/attach:rw"
        ];
      };
    };
  };
}
