{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "sonarr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
    # "sonarr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.authentik-server.networking.ports.http.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      sonarr = {
        image = "ghcr.io/hotio/sonarr:nightly";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["sonarr"];
          ports = {
            webui = {
              host = 9040;
              internal = 8989;
              protocol = "tcp";
          	};
          };
        };
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
          UMASK = "002";
        };
        volumes = [
          # "/mnt/hdd/media:/storage/media:rw"
          # "/mnt/hdd/torrents:/storage/torrents:rw"
          "/mnt/hdd:/storage:rw"
          "/mnt/ssd/services/sonarr/config:/config:rw"
        ];
        # Idea
        # volumes = {
        #   dirs = {
        #     config = {
        #       hostPath = "/mnt/ssd/services/sonarr/config"; # Path on host machine
        #       containerPath = "/config"; # Path in container
        #       mode = "rw"; # Access mode
        #       autoCreate = true; # Whether to create hostPath automatically, if it doesn't exists (systemd tmpfiles). default: true
        #     }
        #   };
        #   files = {
        #     ...
        #   }
        # };
        labels = [
          # Reverse Proxy
          "traefik.enable=true"
          "traefik.port=8989"
          "traefik.http.routers.sonarr.rule=Host(`sonarr.mgrlab.dk`)"
          "traefik.http.routers.sonarr.entrypoints=local"
          # "traefik.http.routers.sonarr.middlewares=authentik@docker"

          # Monitoring
          "kuma.sonarr.http.name=Sonarr"
          "kuma.sonarr.http.url=https://sonarr.mgrlab.dk/ping"
          "kuma.bazarr.http.headers={CF-Access-Client-Id: 46fde907343e7518c533a6b1a240478e.access, CF-Access-Client-Secret: 072f810bc4ab035db956a9f71c2096268e33dc940b90d2c924ecabc381f01ed5}{CF-Access-Client-Id: 46fde907343e7518c533a6b1a240478e.access, CF-Access-Client-Secret: 072f810bc4ab035db956a9f71c2096268e33dc940b90d2c924ecabc381f01ed5}"
        ];
      };
    };
  };

  # prometheus exporters
  services.prometheus.exporters = {
    exportarr-sonarr = {
      enable = true;
      user = "michael";
      group = "users";
      url = "http://localhost:${config.virtualisation.oci-containers.compose.mediaserver.containers.sonarr.networking.ports.webui.host |> builtins.toString}";
      openFirewall = true;
      apiKeyFile = config.sops.secrets.SONARR_API_KEY.path;
      port = config.virtualisation.oci-containers.compose.mediaserver.containers.sonarr.networking.ports.webui.host + 1;
    };
  };
}