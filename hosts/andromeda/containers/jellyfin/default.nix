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
        ];
        devices = [ "/dev/dri" ];
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
