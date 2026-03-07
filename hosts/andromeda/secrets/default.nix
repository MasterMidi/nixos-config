{ config, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.sops.yaml;
    secrets = {
      SONARR_API_KEY = {
        # owner = config.services.prometheus.exporters.exportarr-sonarr.user;
        # group = config.services.prometheus.exporters.exportarr-sonarr.group;
      };
      RADARR_API_KEY = {
        # owner = config.services.prometheus.exporters.exportarr-radarr.user;
        # group = config.services.prometheus.exporters.exportarr-radarr.group;
      };
      # BAZARR_API_KEY = {
      #   owner = config.services.prometheus.exporters.exportarr-bazarr.user;
      #   group = config.services.prometheus.exporters.exportarr-bazarr.group;
      # };
      PROWLARR_API_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      JELLYFIN_TCM_API_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
        restartUnits = [ ];
      };
      AIRVPN_WIREGUARD_PRIVATE_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      AIRVPN_WIREGUARD_PRESHARED_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      TMDB_API_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      BITMAGNET_POSTGRES_PASSWORD = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      AUTHENTIK_POSTGRES_PASSWORD = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      AUTHENTIK_SECRET_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      JELLYFIN_MEILISEARCH_MASTER_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      IMMICH_POSTGRES_PASSWORD = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      KARAKEEP_SECRET = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      KARAKEEP_OAUTH_CLIENT_SECRET = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      KARAKEEP_MEILISEARCH_MASTER_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      UPTIME_KUMA_PASSWORD = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      RECYCLARR_APPRISE_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      QBITMANAGE_GOTIFY_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      QBIT_PUBLIC_PASSWORD = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      QBIT_PRIVATE_PASSWORD = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      CROSS_SEED_PRIVATE_API_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      CROSS_SEED_PRIVATE_APPRISE_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      PANGOLIN_NEWT_SECRET = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      PAPERLESS_POCKETID_CLIENT_SECRET = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      PREFETCHARR_JELLYFIN_API_KEY = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      MEALIE_OIDC_CLIENT_SECRET = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      OPEN_WEBUI_OIDC_CLIENT_SECRET = {
        owner = config.users.users.michael.name;
        group = config.users.groups.users.name;
      };
      ATTIC_SECRET_BASE64 = {
        # owner = config.services.atticd.user;
        # group = config.services.atticd.group;
        format = "dotenv";
        sopsFile = ./attic.env;
      };
    };
  };
}
