{ config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      prefetcharr = {
        image = "docker.io/phueber/prefetcharr:latest";
        autoUpdate = "registry";
        networking = {
          networks = [ "default" ];
          aliases = [ "prefetcharr" ];
        };
        environment = {
          MEDIA_SERVER_TYPE = "jellyfin";
          MEDIA_SERVER_URL = "http://jellyfin:8096";
          SONARR_URL = "http://sonarr:8989";
          LOG_DIR = "/log";
          RUST_LOG = "prefetcharr=debug";
          INTERVAL = "900";
          REMAINING_EPISODES = "4";
        };
        secrets.env = {
          MEDIA_SERVER_API_KEY.path = config.sops.secrets.PREFETCHARR_JELLYFIN_API_KEY.path;
          SONARR_API_KEY.path = config.sops.secrets.SONARR_API_KEY.path;
        };
        volumes = [
          "/mnt/ssd/services/prefetcharr/log:/log"
        ];
      };
    };
  };
}
