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
          "${./configs/recyclarr.yml}:/config/recyclarr.yml"
          "${./configs/recyclarr.settings.yml}:/config/settings.yml"
        ];
        environment={
          TZ = config.time.timeZone;
        };
      };
    };
  };
}