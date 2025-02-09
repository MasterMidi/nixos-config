{config,...}:{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      recyclarr={
        image= "ghcr.io/recyclarr/recyclarr";
        autoUpdate = "registry";
        networking= {networks = ["default"];};
        user = "root";
        volumes=[
          "/mnt/ssd/services/recyclarr/config:/config"
          "${config.sops.secrets.RECYCLARR_CONF.path}:/config/recyclarr.yml"
          "${config.sops.secrets.RECYCLARR_SETTINGS.path}:/config/settings.yml"
        ];
        environment={
          TZ = config.time.timeZone;
        };
      };
    };
  };
}