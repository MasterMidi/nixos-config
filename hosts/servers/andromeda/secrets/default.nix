{config, ...}: {
  sops.secrets = {
    SONARR_API_KEY = {
      owner = config.services.prometheus.exporters.exportarr-sonarr.user;
      group = config.services.prometheus.exporters.exportarr-sonarr.group;
      sopsFile = ./secrets.yaml;
    };
    RADARR_API_KEY = {
      owner = config.services.prometheus.exporters.exportarr-radarr.user;
      group = config.services.prometheus.exporters.exportarr-radarr.group;
      sopsFile = ./secrets.yaml;
    };
    BAZARR_API_KEY = {
      owner = config.services.prometheus.exporters.exportarr-bazarr.user;
      group = config.services.prometheus.exporters.exportarr-bazarr.group;
      sopsFile = ./secrets.yaml;
    };
    CLOUDFLARED_CRED_FILE = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
    #   restartUnits = ["podman-mediaserver-gluetun-secret-OPENVPN_USER.service"];
      sopsFile = ./secrets.yaml;
    };
    CLOUDFLARED_CERT = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
    #   restartUnits = ["podman-mediaserver-gluetun-secret-OPENVPN_USER.service"];
      sopsFile = ./secrets.yaml;
    };
    AIRVPN_WIREGUARD_PRIVATE_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    AIRVPN_WIREGUARD_PRESHARED_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    TMDB_API_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    BITMAGNET_POSTGRES_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    AUTHENTIK_POSTGRES_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    AUTHENTIK_SECRET_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    JELLYSEARCH_MEILISEARCH_MASTER_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    IMMICH_POSTGRES_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    HOARDER_SECRET = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    HOARDER_AUTHENTIK_OAUTH_CLIENT_SECRET = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    HOARDER_MEILISEARCH_MASTER_KEY = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
    UPTIME_KUMA_PASSWORD = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      sopsFile = ./secrets.yaml;
    };
  };
}
