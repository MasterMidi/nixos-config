{config,...}:{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      traefik={
        image = "traefik:v3.2";
        networking = {
          networks = ["default"];
          ports = {
            dashboard = {
              host = 8081;
              internal = 8080;
            };
            local = {
              host = 80;
              internal = 80;
            };
            localsecure = {
              host = 443;
              internal = 443;
            };
            web = {
              host = 7081;
              internal = 7081;
            };
            websecure = {
              host = 7443;
              internal = 7443;
            };
          };
        };
        commands = [
          # API and Dashboard
          "--api=true"
          "--api.dashboard=true"
          "--api.insecure=true"
          # Docker/Podman provider
          "--providers.docker=true"
          "--providers.docker.exposedByDefault=false"
          # "--providers.docker.network=proxy"
          # Entrypoints
          "--entrypoints.web.address=:7081"
          "--entrypoints.websecure.address=:7443"
          "--entryPoints.local.address=:80"
          "--entryPoints.local.transport.respondingTimeouts.readTimeout=600s"
          "--entryPoints.local.transport.respondingTimeouts.idleTimeout=600s"
          "--entryPoints.local.transport.respondingTimeouts.writeTimeout=600s"
          "--entryPoints.localsecure.address=:443"
          # HTTP3 support
          "--entrypoints.local.http3"
          # HTTP to HTTPS redirect
          "--entrypoints.web.http.redirections.entryPoint.to=websecure"
          "--entrypoints.web.http.redirections.entryPoint.scheme=https"
          # Metrics
          "--metrics.prometheus=true"
          # Access Logs
          "--log.level=DEBUG"
          "--log.filepath=/config/log.log"
          "--log.maxAge=3"
          "--log.maxSize=100"
          "--accesslog=true"
          "--accesslog.format=json"
          "--accesslog.filepath=/config/access.log"
          "--accesslog.bufferingSize=1000"
          # Experimental features
          "--experimental.fastProxy" # a new proxy implementation, no http2 support
        ];
        volumes=[
          "/mnt/ssd/services/traefik/config:/config:rw"
          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        ];
      };
    };
  };
}