{ config, ... }:
{
  sops.secrets = {
    SONARR_API_KEY = {
      owner = config.services.prometheus.exporters.exportarr-sonarr.user;
      group = config.services.prometheus.exporters.exportarr-sonarr.group;
      sopsFile = ./secrets.sops.yaml;
    };
    RADARR_API_KEY = {
      owner = config.services.prometheus.exporters.exportarr-radarr.user;
      group = config.services.prometheus.exporters.exportarr-radarr.group;
      sopsFile = ./secrets.sops.yaml;
    };
    # BAZARR_API_KEY = {
    #   owner = config.services.prometheus.exporters.exportarr-bazarr.user;
    #   group = config.services.prometheus.exporters.exportarr-bazarr.group;
    #   sopsFile = ./secrets.sops.yaml;
    # };
    PROWLARR_API_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    JELLYFIN_TCM_API_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      restartUnits = [ ];
      sopsFile = ./secrets.sops.yaml;
    };
    AIRVPN_WIREGUARD_PRIVATE_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    AIRVPN_WIREGUARD_PRESHARED_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    TMDB_API_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    BITMAGNET_POSTGRES_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    AUTHENTIK_POSTGRES_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    AUTHENTIK_SECRET_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    JELLYFIN_MEILISEARCH_MASTER_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    IMMICH_POSTGRES_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    KARAKEEP_SECRET = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    KARAKEEP_OAUTH_CLIENT_SECRET = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    KARAKEEP_MEILISEARCH_MASTER_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    UPTIME_KUMA_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    RECYCLARR_APPRISE_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    QBITMANAGE_GOTIFY_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    QBIT_PUBLIC_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    QBIT_PRIVATE_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    CROSS_SEED_PRIVATE_API_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    CROSS_SEED_PRIVATE_APPRISE_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    PANGOLIN_NEWT_SECRET = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    PAPERLESS_POCKETID_CLIENT_SECRET = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    PREFETCHARR_JELLYFIN_API_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    MEALIE_OIDC_CLIENT_SECRET = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    OPEN_WEBUI_OIDC_CLIENT_SECRET = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.sops.yaml;
    };
    ATTIC_SECRET_BASE64 = {
      # owner = config.services.atticd.user;
      # group = config.services.atticd.group;
      format = "dotenv";
      sopsFile = ./attic.env;
    };
  };
}
