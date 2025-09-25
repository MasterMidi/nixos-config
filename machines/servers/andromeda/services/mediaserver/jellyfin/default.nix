{ config, ... }:
{
  imports = [
    ./aura.nix
    ./fonts.nix
    # ./jellysearch.nix
  ];

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      jellyfin = rec {
        image = "lscr.io/linuxserver/jellyfin:latest";
        autoUpdate = "registry";
        networking = {
          networks = [ "default" ];
          aliases = [ "jellyfin" ];
          ports = {
            webui = {
              host = 8096;
              internal = 8096;
              protocol = "tcp";
            };
          };
        };
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = builtins.toString config.users.users.michael.uid;
          TZ = config.time.timeZone;
        };
        volumes = [
          "/mnt/hdd/media:/storage/media:rw"
          "/mnt/ssd/services/jellyfin/config:/config:rw"
          "/mnt/ssd/services/jellyfin/transcodes:/transcodes:rw"
          # "/mnt/ssd/services/jellyfin/web:/usr/share/jellyfin/web:rw"
        ];
        devices = [ "/dev/dri" ];
        labels = [
          # Reverse Proxy
          ## Enable Traefik for this service
          "traefik.enable=true"
          ## HTTP Router Configuration
          "traefik.http.routers.jellyfin.entryPoints=local"
          "traefik.http.routers.jellyfin.rule=Host(`jellyfin.mgrlab.dk`)"
          ## Middleware Configuration
          "traefik.http.routers.jellyfin.middlewares=jellyfin-headers"
          ## Security Headers
          "traefik.http.middlewares.jellyfin-headers.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex"
          "traefik.http.middlewares.jellyfin-headers.headers.contentTypeNosniff=true"
          "traefik.http.middlewares.jellyfin-headers.headers.customResponseHeaders.X-XSS-Protection=1"
          "traefik.http.middlewares.jellyfin-headers.headers.customFrameOptionsValue=allow-from https://jellyfin.mgrlab.dk"
          ## Service Configuration
          "traefik.http.services.jellyfin.loadbalancer.server.port=${toString networking.ports.webui.internal}"
          "traefik.http.services.jellyfin.loadbalancer.passHostHeader=true"

          # Monitoring
          "kuma.jellyfin.http.name=Jellyfin"
          "kuma.jellyfin.http.url=https://jellyfin.mgrlab.dk/health"
        ];
        extraOptions = [
          "--gpus=all"
        ];
      };

      # https://github.com/arnesacnussem/jellyfin-plugin-meilisearch
      jellyfin-meilisearch = {
        image = "getmeili/meilisearch:v1.9";
        networking = {
          networks = [ "default" ];
          aliases = [ "jellyfin-meilisearch" ];
        };
        volumes = [ "/mnt/ssd/services/jellyfin/meilisearch:/meili_data:rw" ];
        secrets.env = {
          MEILI_MASTER_KEY.path = config.sops.secrets.JELLYFIN_MEILISEARCH_MASTER_KEY.path;
        };
      };
    };
  };

  systemd.services.podman-mediaserver-jellyfin.serviceConfig = {
    IOSchedulingClass = "best-effort"; # Default class but with lower priority
    IOSchedulingPriority = 0; # Range is 0-7, with 7 being lowest priority
    Nice = -10; # Medium-high priority
  };

  hardware.nvidia-container-toolkit.enable = true; # Enable NVIDIA GPU support
  services.xserver.videoDrivers = [ "nvidia" ];

  users.users.michael = {
    extraGroups = [ "media" ];
  };
}
