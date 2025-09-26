{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "radarr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      radarr = {
        image = "lscr.io/linuxserver/radarr:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["radarr"];
          ports = {
            webui = {
              host = 9030;
              internal = 7878;
              protocol = "tcp";
            };
          };
        };
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
        };
        volumes = [
          # "/mnt/hdd/media:/storage/media:rw"
          # "/mnt/hdd/torrents:/storage/torrents:rw"
          "/mnt/hdd:/storage:rw"
          "/mnt/ssd/services/radarr/config:/config:rw"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.port: 7878"
          "traefik.http.routers.radarr.rule=Host(`radarr.mgrlab.dk`)"
          "traefik.http.routers.radarr.entrypoints=local"

          # Monitoring
          "kuma.radarr.http.name=Radarr"
          "kuma.radarr.http.url=https://radarr.mgrlab.dk/ping"
        ];
      };
    };
  };

  # prometheus exporters
  services.prometheus.exporters = {
    exportarr-radarr = {
      enable = true;
      user = "michael";
      group = "users";
      url = "http://localhost:${config.virtualisation.oci-containers.compose.mediaserver.containers.radarr.networking.ports.webui.host |> builtins.toString}";
      openFirewall = true;
      apiKeyFile = config.sops.secrets.RADARR_API_KEY.path;
      port = 9031;
    };
  };
}