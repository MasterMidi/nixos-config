{config,...}:{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      scrutiny={
        image= "ghcr.io/analogj/scrutiny:master-omnibus";
        autoUpdate = "registry";
        networking= {
            networks = ["default"];
          ports = {
            webui = {
              host = 8888;
              internal = 8080;
            };
            extra = {
              host = 8086;
              internal = 8086;
            };
          };
        };
        volumes=[
          "/mnt/ssd/services/scrutiny/config:/opt/scrutiny/config"
          "/mnt/ssd/services/scrutiny/data:/opt/scrutiny/influxdb"
          "/run/udev:/run/udev:ro"
        ];
        environment={
          TZ = config.time.timeZone;
        };
        devices = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/sdc"
        ];
        capabilities = [
          "SYS_RAWIO"
          "SYS_ADMIN"
        ];
      };
    };
  };
}
