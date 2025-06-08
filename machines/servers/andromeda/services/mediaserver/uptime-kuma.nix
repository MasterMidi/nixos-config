{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "kuma.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
    "status.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = rec {
      uptime-kuma = {
        image = "docker.io/louislam/uptime-kuma";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["kuma"];
          ports = {
            webui = {
              host = 3001;
              internal = 3001;
            };
          };
        };
        volumes = [
          "/mnt/ssd/services/uptime-kuma/config:/app/data"
          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.port: 3001"
          "traefik.http.routers.uptime-kuma.rule=Host(`kuma.mgrlab.dk`) || Host(`status.mgrlab.dk`)"
          "traefik.http.routers.uptime-kuma.entrypoints=local"
        ];
      };

      autokuma = {
        image = "ghcr.io/bigboot/autokuma:latest";
        dependsOn = ["uptime-kuma"];
        environment = {
          AUTOKUMA__KUMA__URL = "http://kuma:${toString uptime-kuma.networking.ports.webui.internal}";
          AUTOKUMA__KUMA__USERNAME = "admin"; 
          # AUTOKUMA__KUMA__CALL_TIMEOUT: 5
          # AUTOKUMA__KUMA__CONNECT_TIMEOUT: 5
          # AUTOKUMA__TAG_NAME = "AutoKuma";
          # AUTOKUMA__TAG_COLOR: "#42C0FB"
          # AUTOKUMA__DEFAULT_SETTINGS: |- 
          #    docker.docker_container: {{container_name}}
          #    http.max_redirects: 10
          #    \*.max_retries: 3
          # AUTOKUMA__SNIPPETS__WEB: |- 
          #    {{container_name}}_http.http.name: {{container_name}} HTTP
          #    {{container_name}}_http.http.url: https://{{@0}}:{{@1}}
          #    {{container_name}}_docker.docker.name: {{container_name}} Docker
          #    {{container_name}}_docker.docker.docker_container: {{container_name}}
          # AUTOKUMA__DOCKER__HOSTS: unix:///var/run/docker.sock
          # AUTOKUMA__DOCKER__LABEL_PREFIX: kuma
        };
        secrets.env = {
          AUTOKUMA__KUMA__PASSWORD.path = config.sops.secrets.UPTIME_KUMA_PASSWORD.path;
        };
        volumes = [
          "/mnt/ssd/services/autokuma/data:/data"
          "/var/run/podman/podman.sock:/var/run/docker.sock"
        ];
      };
    };
  };
}