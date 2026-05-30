{ ... }:
let
  app = "recyclarr";
  image = "ghcr.io/recyclarr/recyclarr:8.6.0";
in
{
  kubernetes.resources.media-stack = {
    Secret."${app}-secret" = {
      stringData = {
        radarr_api_key = "{{ secrets.radarr_api_key }}";
        sonarr_api_key = "{{ secrets.sonarr_api_key }}";
      };
    };

    ConfigMap."${app}-config" = {
      data."recyclarr.yml" = ''
        # yaml-language-server: $schema=https://schemas.recyclarr.dev/v8/config-schema.json
        radarr:
          main:
            base_url: http://radarr:7878
            api_key: !file /run/recyclarr-secrets/radarr_api_key
            delete_old_custom_formats: true

            quality_definition:
              type: movie

            quality_profiles:
              - trash_id: 64fb5f9858489bdac2af690e27c8f42f # UHD Bluray + WEB
                reset_unmatched_scores:
                  enabled: true
              - trash_id: 722b624f9af1e492284c4bc842153a38 # [Anime] Remux-1080p
                reset_unmatched_scores:
                  enabled: true

            media_naming:
              folder: jellyfin
              movie:
                rename: true
                standard: anime-jellyfin

            custom_format_groups:
              add:
                - trash_id: ff204bbcecdd487d1cefcefdbf0c278d # [Optional] Golden Rule UHD
                  assign_scores_to:
                    - trash_id: 64fb5f9858489bdac2af690e27c8f42f # UHD Bluray + WEB
                  exclude:
                    - dc98083864ea246d05a42df0d05f81cc # x265 (HD)
                  select:
                    - 839bea857ed2c0a8e084f3cbdbd65ecb # x265 (no HDR/DV)
                - trash_id: a3ac6af01d78e4f21fcb75f601ac96df # [Unwanted] Unwanted Formats
                  assign_scores_to:
                    - trash_id: 64fb5f9858489bdac2af690e27c8f42f # UHD Bluray + WEB
                  select:
                    - b8cd450cbfa689c0259a01d9e29ba3d6 # 3D
                    - cae4ca30163749b891686f95532519bd # AV1
                    - b6832f586342ef70d9c128d40c07b872 # Bad Dual Groups
                    - ed38b889b31be83fda192888e2286d83 # BR-DISK
                    - 0a3f082873eb454bde444150b70253cc # Extras
                    - 90a6f9a284dff5103f6346090e6280c8 # LQ
                    - e204b80c87be9497a8a6eaff48f72905 # LQ (Release Title)
                    - ae9b7c9ebde1f3bd336a8cbd1ec4c5e5 # No-RlsGroup
                    - 7357cf5161efbf8c4d5d0c30b4815ee2 # Obfuscated
                    - 5c44f52a8714fdd79bb4d98e2673be1f # Retags
                    - f537cf427b64c38c8e36298f657e4828 # Scene
                    - bfd8eb01832d646a0a89c4deb46f8564 # Upscaled
                - trash_id: f4f1474b963b24cf983455743aa9906c # [Optional] Movie Versions
                  assign_scores_to:
                    - trash_id: 64fb5f9858489bdac2af690e27c8f42f # UHD Bluray + WEB
                  select:
                    - eca37840c13c6ef2dd0262b141a5482f # 4K Remaster
                    - e0c07d59beb37348e975a930d5e50319 # Criterion Collection
                    - eecf3a857724171f968a66cb5719e152 # IMAX
                    - 9f6cbff8cfe4ebbc1bde14c7b7bec0de # IMAX Enhanced
                    - 9d27d9d2181838f76dee150882bdc58c # Masters of Cinema
                    - 570bc9ebecd92723d2d21500f4be314c # Remaster
                    - 957d0f44b592285f26449575e8b1167e # Special Edition
                    - db9b4c4b53d312a3ca5f1378f6440fc9 # Vinegar Syndrome

        sonarr:
          main:
            base_url: http://sonarr:8989
            api_key: !file /run/recyclarr-secrets/sonarr_api_key
            delete_old_custom_formats: true

            quality_definition:
              type: series

            quality_profiles:
              - trash_id: 72dae194fc92bf828f32cde7744e51a1 # WEB-1080p
                reset_unmatched_scores:
                  enabled: true
              - trash_id: 20e0fc959f1f1704bed501f23bdae76f # [Anime] Remux-1080p
                reset_unmatched_scores:
                  enabled: true

            media_naming:
              episodes:
                anime: default
                daily: default
                rename: true
                standard: default
              season: default
              series: jellyfin

            custom_format_groups:
              add:
                - trash_id: 158188097a58d7687dee647e04af0da3 # [Optional] Golden Rule HD
                  assign_scores_to:
                    - trash_id: 72dae194fc92bf828f32cde7744e51a1 # WEB-1080p
                  select:
                    - 47435ece6b99a0b477caf360e79ba0bb # x265 (HD)
                - trash_id: 85fae4a2294965b75710ef2989c850eb # [Streaming Services] HD/UHD boost
                  assign_scores_to:
                    - trash_id: 72dae194fc92bf828f32cde7744e51a1 # WEB-1080p
                  select:
                    - 218e93e5702f44a68ad9e3c6ba87d2f0 # HD Streaming Boost
                    - 43b3cf48cb385cd3eac608ee6bca7f09 # UHD Streaming Boost
                - trash_id: 59c3af66780d08332fdc64e68297098f # [Unwanted] Unwanted Formats
                  assign_scores_to:
                    - trash_id: 72dae194fc92bf828f32cde7744e51a1 # WEB-1080p
                  select:
                    - 15a05bc7c1a36e2b57fd628f8977e2fc # AV1
                    - 32b367365729d530ca1c124a0b180c64 # Bad Dual Groups
                    - 85c61753df5da1fb2aab6f2a47426b09 # BR-DISK
                    - 6f808933a71bd9666531610cb8c059cc # BR-DISK (BTN)
                    - fbcb31d8dabd2a319072b84fc0b7249c # Extras
                    - 9c11cd3f07101cdba90a2d81cf0e56b4 # LQ
                    - e2315f990da2e2cbfc9fa5b7a6fcfe48 # LQ (Release Title)
                    - 82d40da2bc6923f41e14394075dd4b03 # No-RlsGroup
                    - e1a997ddb54e3ecbfe06341ad323c458 # Obfuscated
                    - 06d66ab109d4d2eddb2794d21526d140 # Retags
                    - 1b3994c551cbb92a2c781af061f4ab44 # Scene
                    - 23297a736ca77c0fc8e70f8edd7ee56c # Upscaled
                - trash_id: f54985e5e96747cef58731f1cf4c9181 # [Streaming Services] Anime
                  assign_scores_to:
                    - trash_id: 20e0fc959f1f1704bed501f23bdae76f # [Anime] Remux-1080p
                  select:
                    - a370d974bc7b80374de1d9ba7519760b # ABEMA
                    - d54cd2bf1326287275b56bccedb72ee2 # ADN
                    - 7dd31f3dee6d2ef8eeaa156e23c3857e # B-Global
                    - 4c67ff059210182b59cdd41697b8cb08 # Bilibili
                    - 3e0b26604165f463f3e8e192261e7284 # CR
                    - 1284d18e693de8efe0fe7d6b3e0b9170 # FUNi
                    - 570b03b3145a25011bf073274a407259 # HIDIVE
                    - 44a8ee6403071dd7b8a3a8dd3fe8cb20 # VRV
                    - e5e6405d439dcd1af90962538acd4fe0 # WKN
      '';
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
                # securityContext = {
                #   runAsUser = 3000;
                #   runAsGroup = 3000;
                #   fsGroup = 3000;
                # };
                env = {
                  _namedlist = true;
                  TZ.value = "Europe/Copenhagen";
                  CRON_SCHEDULE.value = "@daily";
                };
                volumeMounts = {
                  _namedlist = true;
                  config.mountPath = "/config";
                  configs = {
                    mountPath = "/config/recyclarr.yml";
                    subPath = "recyclarr.yml";
                    readOnly = true;
                  };
                  "secret-files".mountPath = "/run/recyclarr-secrets";
                };
              };
            };
            volumes = {
              _namedlist = true;
              config.hostPath = {
                path = "/mnt/ssd/appdata/recyclarr/config";
                type = "DirectoryOrCreate";
              };
              configs.configMap.name = "${app}-config";
              "secret-files".secret.secretName = "${app}-secret";
            };
          };
        };
      };
    };
  };
}
