{ ... }:
{
  virtualisation.oci-containers.compose.mediaserver.containers.tailscale = rec {
    image = "ghcr.io/tailscale/tailscale:latest";
    networking = {
      networks = [ "default" ];
      aliases = [ "tasilscale" ];
    };
    volumes = [
      "/mnt/ssd/services/tailscale/state:${environment.TS_STATE_DIR}"
      "/dev/net/tun:/dev/net/tun"
    ];
    environment = {
      TS_AUTHKEY = "tskey-auth-kT57jdZXt211CNTRL-XLoDx3QJPrB2A6xQqHzSsByu1dnfHqq6";
      TS_STATE_DIR = /var/lib/tailscale;
    };
    secrets.env = {
      # TS_AUTHKEY.path = config.sops.secrets.TAILSCALE_AUTH_KEY_EPHEMERAL.path;
    };
    capabilities = [
      "NET_ADMIN"
      "NET_RAW"
    ];
  };
}
