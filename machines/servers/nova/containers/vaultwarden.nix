{ ... }:
{
  virtualisation.oci-containers.compose.tunnel.containers = {
    vaultwarden = {
      image = "docker.io/vaultwarden/server:latest-alpine";
      autoUpdate = "registry";
      networking = {
        networks = [ "default" ];
        aliases = [ "vaultwarden" ];
      };
      environment = {
        DOMAIN = "https://vaultwarden.mgrlab.dk";
        SIGNUPS_ALLOWED = "false";
      };
      volumes = [
        "/mnt/ssd/services/vaultwarden/data:/data"
      ];
    };
  };
}
