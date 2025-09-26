{config,lib,...}:{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      title-card-maker = {
        image = "collinheist/titlecardmaker:develop";
        # autoUpdate = "registry";
        networking = {
          networks = ["default"];
          # aliases = ["titleCardMaker"];
        };
        environment = {
          TCM_MISSING="/config/missing.yml";
          TCM_RUNTIME="22:00" ;
          TCM_FREQUENCY="12h";
        };
        volumes = [
          "/mnt/ssd/services/titleCardMaker/config:/config:rw"
          "${config.sops.templates.TCM_CONF.path}:/config/preferences.yml:rw"
          "/mnt/ssd/services/titleCardMaker/logs:/maker/logs:rw"
          "/mnt/hdd/media:/Media:rw"
        ];
      };
    };
  };

  sops.templates.TCM_CONF = {
    owner = config.users.users.michael.name;
    group = config.users.groups.users.name;
    restartUnits = [config.virtualisation.oci-containers.compose.mediaserver.containers.title-card-maker.unitName];
    content = lib.generators.toYAML {} {
      options = {
        source = "/config/source/";3
        series = [
          "/config/yaml/sonarr_sync_tv.yml"
          "/config/yaml/sonarr_sync_anime.yml"
        ];
        filename_format = "{full_name} - S{season:02}E{episode:02}";
        season_folder_format = "Season {season:02}";
        sync_specials = false;
      };

      # jellyfin = {
      #   url = "http://jellyfin:8096/";
      #   api_key = config.sops.placeholder.JELLYFIN_TCM_API_KEY;
      #   username = "admin";
      #   sync = [
      #     {
      #       card_directory = "/config/cards";
      #       mode = "sync";
      #     }
      #     {
      #       file = "/config/jellyfin_sync_tv.yml";
      #       libraries = [
      #         "Shows"
      #       ];
      #     }
      #     {
      #       file = "/config/jellyfin_sync_anime.yml";
      #       libraries = [
      #         "Anime"
      #       ];
      #     }
      #   ];
      # };

      sonarr = {
        url = "http://${builtins.head config.virtualisation.oci-containers.compose.mediaserver.containers.sonarr.networking.aliases}:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.sonarr.networking.ports.webui.internal}/api/v3/";
        api_key = config.sops.placeholder.SONARR_API_KEY;
        downloaded_only = true;
        sync = [
          {
            file = "/config/yaml/sonarr_sync_tv.yml";
            mode = "match";
            compact_mode = true;
            monitored_only = true;
            add_template = "template";
            volumes = {
              "/storage/media/tvseries" = "/maker/media/tv";
            };
          }
          {
            file = "/config/yaml/sonarr_sync_anime.yml";
            mode = "match";
            compact_mode = true;
            monitored_only = true;
            add_template = "template";
            volumes = {
              "/storage/media/anime" = "/maker/media/anime";
            };
          }
        ];
      };

      tmdb = {
        api_key = config.sops.placeholder.TMDB_API_KEY;
      };
    };
  };
}


python /maker/mini_maker.py --movie-poster "/Media/animated-movies/Treasure Planet (2002) [imdbid-tt0133240]/folder.jpg" "/Media/animated-movies/Treasure Planet (2002) [imdbid-tt0133240]/poster.tcm.jpg" --movie-logo "/Media/animated-movies/Treasure Planet (2002) [imdbid-tt0133240]/logo.png"