{ config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      stirling-pdf = {
        image = "docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest";
        autoUpdate = "registry";
        networking = {
          networks = [ "default" ];
          aliases = [ "stirlingpdf" ];
          ports.webui = {
            host = 9999;
            internal = 8080;
            protocol = "tcp";
          };
        };
        environment = {
          DOCKER_ENABLE_SECURITY = "false";
          LANGS = "en_GB";
        };
        volumes = [
          "/mnt/ssd/services/stirlingpdf/training_data:/usr/share/tessdata"
          "/mnt/ssd/services/stirlingpdf/extra_configs:/configs"
          "/mnt/ssd/services/stirlingpdf/custom_files:/customFiles/"
          "/mnt/ssd/services/stirlingpdf/logs:/logs/"
          "/mnt/ssd/services/stirlingpdf/pipeline:/pipeline/"
        ];
      };
    };
  };
}
