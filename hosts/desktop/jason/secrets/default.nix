{config, ...}: {
  sops.secrets = {
    SONARR_API_KEY = {
      owner = config.services.prometheus.exporters.exportarr-sonarr.user;
      group = config.services.prometheus.exporters.exportarr-sonarr.group;
      sopsFile = ./servarr.yaml;
    };
    RADARR_API_KEY = {
      owner = config.services.prometheus.exporters.exportarr-radarr.user;
      group = config.services.prometheus.exporters.exportarr-radarr.group;
      sopsFile = ./servarr.yaml;
    };
    BAZARR_API_KEY = {
      owner = config.services.prometheus.exporters.exportarr-bazarr.user;
      group = config.services.prometheus.exporters.exportarr-bazarr.group;
      sopsFile = ./servarr.yaml;
    };
  };
}
