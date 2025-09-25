{ ... }:
{
  virtualisation.oci-containers.compose.mediaserver.containers.pocket-id = rec {
    image = "ghcr.io/pocket-id/pocket-id:v1.11.1";
    networking = {
      networks = [ "default" ];
      aliases = [ "pocket-id" ];
      ports.default = {
        host = 1411;
        internal = 1411;
      };
    };
    volumes = [
      "/mnt/ssd/services/pocket-id/data:/app/data"
    ];
    environment = {
      APP_URL = "https://oidc.mgrlab.dk";
      TRUST_PROXY = "true";
      MAXMIND_LICENSE_KEY = "";
      PUID = "1000";
      PGID = "100";
    };
    secrets.env = {
      # MAXMIND_LICENSE_KEY.path = config.sops.secrets.PANGOLIN_NEWT_SECRET.path;
    };
    labels = [
      "traefik.enable=true"
      "traefik.http.routers.pocket-id.rule=Host(`oidc.mgrlab.dk`)"
      "traefik.http.routers.pocket-id.entrypoints=local"
      "traefik.http.routers.pocket-id.service=pocket-id"
      "traefik.http.services.pocket-id.loadbalancer.server.port=${toString networking.ports.default.internal}"
    ];
  };
}
