{ ... }:
let
  app = "subgen";
  # We use the base image which supports both CPU and GPU (as per readme)
  image = "docker.io/mccloud/subgen:latest";
  port = 9000;
in
{
  kubernetes.resources.media-stack = {
    Service.${app} = {
      spec = {
        ports = {
          _namedlist = true;
          http = {
            inherit port;
            targetPort = port;
          };
        };
        selector = { inherit app; };
      };
    };

    Deployment.${app} = {
      spec = {
        replicas = 1;
        strategy.type = "Recreate";
        selector.matchLabels = { inherit app; };
        template = {
          metadata.labels = { inherit app; };
          spec = {
            containers = {
              _namedlist = true;
              ${app} = {
                inherit image;
                # GPU Resource Request
                resources.limits."nvidia.com/gpu" = 1;

                env = {
                  _namedlist = true;
                  # Core GPU & Model Settings
                  TRANSCRIBE_DEVICE.value = "cuda";
                  WHISPER_MODEL.value = "large-v3"; # Better for multi-lang than turbo
                  CONCURRENT_TRANSCRIPTIONS.value = "2";

                  # Language & Logic Settings (Danish/English focus)
                  # We skip if English or Danish audio is already tagged to save resources
                  # SKIP_IF_AUDIO_LANGUAGES.value = "eng|dan";
                  # We skip if English subtitles already exist
                  # SKIP_IF_INTERNAL_SUBTITLES_LANGUAGE.value = "eng";

                  # Media Server Integration
                  # JELLYFINSERVER.value = "http://jellyfin:8096";
                  # JELLYFINTOKEN.value = "fcd7d1b6f69d4838a48b97887d747d1f";

                  # Path Mapping (Crucial for Webhooks)
                  # USE_PATH_MAPPING.value = "True";
                  # PATH_MAPPING_FROM.value = "/tv|/movies";
                  # PATH_MAPPING_TO.value = "/tv|/movies";

                  # Formatting
                  # SUBTITLE_LANGUAGE_NAME.value = "dan"; # Forces .dan.srt
                  # DEBUG.value = "True";
                };

                ports = {
                  _namedlist = true;
                  http.containerPort = port;
                };

                volumeMounts = {
                  _namedlist = true;
                  # media.mountPath = "/storage/media";
                  models.mountPath = "/subgen/models";
                };
              };
            };
            volumes = {
              _namedlist = true;
              media.hostPath = {
                path = "/mnt/hdd/media";
                type = "Directory";
              };
              models.hostPath = {
                path = "/mnt/ssd/services/subgen/models";
                type = "DirectoryOrCreate";
              };
            };
          };
        };
      };
    };
  };
}
