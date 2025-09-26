{ config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      bazarr = {
        image = "lscr.io/linuxserver/bazarr:latest";
        autoUpdate = "registry";
        networking = {
          networks = [ "default" ];
          aliases = [ "bazarr" ];
        };
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
          VERBOSITY = "-vv";
        };
        volumes = [
          "/mnt/hdd/media:/storage/media:rw"
          "/mnt/ssd/services/bazarr/config:/config:rw"
        ];
      };
      bazarr2 = {
        image = "lscr.io/linuxserver/bazarr:latest";
        autoUpdate = "registry";
        networking = {
          networks = [ "default" ];
          aliases = [ "bazarr2" ];
        };
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
          VERBOSITY = "-vv";
        };
        volumes = [
          "/mnt/hdd/media:/storage/media:rw"
          "/mnt/ssd/services/bazarr2/config:/config:rw"
        ];
      };
    };
  };

  # prometheus exporters
  # services.prometheus.exporters = {
  #   exportarr-bazarr = {
  #     enable = true;
  #     user = "michael";
  #     group = "users";
  #     url = "http://localhost:${
  #       config.virtualisation.oci-containers.compose.mediaserver.containers.bazarr.networking.ports.webui.host
  #       |> builtins.toString
  #     }";
  #     openFirewall = true;
  #     apiKeyFile = config.sops.secrets.BAZARR_API_KEY.path;
  #     port = 9081;
  #   };
  # };
}
