{ config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver.containers.newt = rec {
    image = "fosrl/newt:1.3.4";
    networking = {
      networks = [ "default" ];
      aliases = [ "newt" ];
    };
    environment = {
      PANGOLIN_ENDPOINT = "https://tunnel.mgrlab.dk";
      NEWT_ID = "ip881cnfiwkx3g2";
      DOCKER_SOCKET = "/var/run/docker.sock";
    };
    secrets.env = {
      NEWT_SECRET.path = config.sops.secrets.PANGOLIN_NEWT_SECRET.path;
    };
    volumes = [
      "/var/run/podman/podman.sock:${environment.DOCKER_SOCKET}:ro"
    ];
  };
}
