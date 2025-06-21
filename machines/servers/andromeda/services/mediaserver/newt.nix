{ config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver.containers.newt = {
    image = "fosrl/newt:1.2.1";
    networking = {
      networks = [ "default" ];
      aliases = [ "newt" ];
    };
    environment = {
      PANGOLIN_ENDPOINT = "https://tunnel.mgrlab.dk";
      NEWT_ID = "ip881cnfiwkx3g2";
    };
    secrets.env = {
      NEWT_SECRET.path = config.sops.secrets.PANGOLIN_NEWT_SECRET.path;
    };
    volumes = [
      "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
    ];
  };
}
