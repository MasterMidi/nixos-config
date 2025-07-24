{ pkgs, config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      aura = {
        image = "ghcr.io/mediux-team/aura:latest";
        autoUpdate = "registry";
        networking = {
          networks = [ "default" ];
          aliases = [ "arua" ];
          ports = {
            webui = {
              host = 3000;
              internal = 3000;
              protocol = "tcp";
            };
            api = {
              host = 9898;
              internal = 8888;
              protocol = "tcp";
            };
          };
        };
        volumes = [
          "/mnt/ssd/services/aura/config:/config"
          "${config.sops.templates.AURA_CONFIG.path}:/config/config.yml"
          "/mnt/hdd/media:/data/media"
        ];
      };
    };
  };

  sops.templates.AURA_CONFIG = {
    # owner = config.users.users.michael.name;
    # group = config.users.groups.users.name;
    restartUnits = [
      config.virtualisation.oci-containers.compose.mediaserver.containers.aura.unitName
    ];
    file = (pkgs.formats.yaml { }).generate "aura_config.yml" {
      CacheImages = true;
      Logging.level = "INFO";
      AutoDownload = {
        Enabled = true;
        Cron = "0 20 * * *";
      };
      MediaServer = {
        Type = "Jellyfin";
        URL = "http://jellyfin:8096";
        Token = "4b55373a945c43879087b4a7b888f5e8";
        Libraries = [
          "Anime"
          "Movies"
          "Shows"
          "Anime Movies"
          "Animated Movies"
        ];
      };
      TMDB.APIKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiMzlmYjhhMjhhYTU5MTg4NDllMjkyYzdmNmFhYzYxMyIsIm5iZiI6MTcyOTk3ODMyOS4yMjcsInN1YiI6IjY3MWQ1ZmQ5NmQ2YjcwNWRjODcxOWQ5NyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.lP6lL5PO8vcKIlCP-sEoKE10gJBoTDqQAqQxo5uFpDY";
      Mediux = {
        APIKey = ""; # TODO: https://mediux-team.github.io/AURA/config#apikey-1
        DownloadQuality = "original";
      };
    };
  };
}
