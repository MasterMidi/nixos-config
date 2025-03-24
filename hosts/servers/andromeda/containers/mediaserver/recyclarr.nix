{config,lib,...}:{
  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      recyclarr={
        image= "ghcr.io/recyclarr/recyclarr";
        autoUpdate = "registry";
        networking= {networks = ["default"];};
        user = "root";
        volumes=[
          "/mnt/ssd/services/recyclarr/config:/config"
          "${config.sops.templates.RECYCLARR_CONF.path}:/config/recyclarr.yml"
          "${config.sops.templates.RECYCLARR_SETTINGS.path}:/config/settings.yml"
        ];
        environment={
          TZ = config.time.timeZone;
        };
      };
    };
  };

  sops.templates = {
    RECYCLARR_CONF = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      restartUnits = [config.virtualisation.oci-containers.compose.mediaserver.containers.recyclarr.unitName];
      content = lib.generators.toYAML {} {
        radarr = {
          radarr = {
            api_key = config.sops.placeholder.RADARR_API_KEY;
            base_url = "http://${builtins.head config.virtualisation.oci-containers.compose.mediaserver.containers.radarr.networking.aliases}:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.radarr.networking.ports.webui.internal}";
            custom_formats = [
              {
                assign_scores_to = [
                  {
                    name = "UHD Bluray + WEB";
                    score = 0;
                  }
                ];
                trash_ids = [
                  "c53085ddbd027d9624b320627748612f"
                  "e23edd2482476e595fb990b12e7c609c"
                  "58d6a88f13e2db7f5059c41047876f00"
                  "55d53828b9d81cbe20b02efd00aa0efd"
                  "a3e19f8f627608af0211acd02bf89735"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "UHD Bluray + WEB";
                  }
                ];
                trash_ids = [
                  "d6e9318c875905d6cfb5bee961afcea9"
                  "a570d4a0e56a2874b64e5bfa55202a1b"
                  "923b6abef9b17f937fab56cfcf89e1f1"
                  "b974a6cd08c1066250f1f177d7aa1225"
                  "dfb86d5941bc9075d6af23b09c2aeecd"
                  "e61e28db95d22bedcadf030b8f156d96"
                  "2a4d9069cc1fe3242ff9bdaebed239bb"
                  "08d6d8834ad9ec87b1dc7ec8148e7a1f"
                  "9364dd386c9b4a1100dde8264690add7"
                  "4d74ac4c4db0b64bff6ce0cffef99bf0"
                  "a58f517a70193f8e578056642178419d"
                  "e71939fae578037e7aed3ee219bbe7c1"
                  "c20f169ef63c5f40c2def54abaf4438e"
                  "403816d65392c79236dcb6dd591aeda4"
                  "af94e0fe497124d1f9ce732069ec8c3b"
                  "e7718d7a3ce595f289bfee26adc178f5"
                  "ae43b294509409a6a13919dedd4764c4"
                  "5caaaa1c08c1742aa4342d8c4cc463f2"
                  "ed38b889b31be83fda192888e2286d83"
                  "90a6f9a284dff5103f6346090e6280c8"
                  "e204b80c87be9497a8a6eaff48f72905"
                  "b8cd450cbfa689c0259a01d9e29ba3d6"
                  "bfd8eb01832d646a0a89c4deb46f8564"
                  "0a3f082873eb454bde444150b70253cc"
                  "cae4ca30163749b891686f95532519bd"
                  "9172b2f683f6223e3a1846427b417a3d"
                  "b3b3a6ac74ecbd56bcdbefa4799fb9df"
                  "40e9380490e748672c2522eaaeb692f7"
                  "cc5e51a9e85a6296ceefe097a77f12f4"
                  "16622a6911d1ab5d5b8b713d5b0036d4"
                  "84272245b2988854bfb76a16e60baea5"
                  "509e5f41146e278f9eab1ddaceb34515"
                  "5763d1b0ce84aff3b21038eea8e9b8ad"
                  "526d445d4c16214309f0fd2b3be18a89"
                  "e0ec9672be6cac914ffad34a6b077209"
                  "6a061313d22e51e0f25b7cd4dc065233"
                  "2a6039655313bf5dab1e43523b62c374"
                  "170b1d363bd8516fbf3a3eb05d4faff6"
                  "e36a0ba1bc902b26ee40818a1d59b8bd"
                  "c9fd353f8f5f1baf56dc601c4cb29920"
                  "c2863d2a50c9acad1fb50e53ece60817"
                  "b6832f586342ef70d9c128d40c07b872"
                  "90cedc1fea7ea5d11298bebd3d1d3223"
                  "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5"
                  "7357cf5161efbf8c4d5d0c30b4815ee2"
                  "5c44f52a8714fdd79bb4d98e2673be1f"
                  "f537cf427b64c38c8e36298f657e4828"
                  "570bc9ebecd92723d2d21500f4be314c"
                  "eca37840c13c6ef2dd0262b141a5482f"
                  "e0c07d59beb37348e975a930d5e50319"
                  "9d27d9d2181838f76dee150882bdc58c"
                  "db9b4c4b53d312a3ca5f1378f6440fc9"
                  "957d0f44b592285f26449575e8b1167e"
                  "eecf3a857724171f968a66cb5719e152"
                  "9f6cbff8cfe4ebbc1bde14c7b7bec0de"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "UHD Bluray + WEB";
                    score = 0;
                  }
                ];
                trash_ids = [
                  "dc98083864ea246d05a42df0d05f81cc"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "UHD Bluray + WEB";
                    score = 101;
                  }
                ];
                trash_ids = [
                  "064af5f084a0a24458cc8ecd3220f93f"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "Anime Remux (1080p)";
                  }
                ];
                trash_ids = [
                  "d6e9318c875905d6cfb5bee961afcea9"
                  "fb3ccc5d5cc8f77c9055d4cb4561dded"
                  "66926c8fa9312bc74ab71bf69aae4f4a"
                  "fa857662bad28d5ff21a6e611869a0ff"
                  "f262f1299d99b1a2263375e8fa2ddbb3"
                  "ca864ed93c7b431150cc6748dc34875d"
                  "9dce189b960fddf47891b7484ee886ca"
                  "1ef101b3a82646b40e0cab7fc92cd896"
                  "6115ccd6640b978234cc47f2c1f2cadc"
                  "8167cffba4febfb9a6988ef24f274e7e"
                  "8526c54e36b4962d340fce52ef030e76"
                  "de41e72708d2c856fa261094c85e965d"
                  "9edaeee9ea3bcd585da9b7c0ac3fc54f"
                  "22d953bbe897857b517928f3652b8dd3"
                  "a786fbc0eae05afe3bb51aee3c83a9d4"
                  "3a3ff47579026e76d6504ebea39390de"
                  "9f98181fe5a3fbeb0cc29340da2a468a"
                  "8baaf0b3142bf4d94c42a724f034e27a"
                  "c20f169ef63c5f40c2def54abaf4438e"
                  "403816d65392c79236dcb6dd591aeda4"
                  "af94e0fe497124d1f9ce732069ec8c3b"
                  "06b6542a47037d1e33b15aa3677c2365"
                  "b0fdc5897f68c9a68c70c25169f77447"
                  "c259005cbaeb5ab44c06eddb4751e70c"
                  "5f400539421b8fcf71d51e6384434573"
                  "3df5e6dfef4b09bb6002f732bed5b774"
                  "db92c27ba606996b146b57fbe6d09186"
                  "d4e5e842fad129a3c097bdb2d20d31a0"
                  "60f6d50cbd3cfc3e9a8c00e3a30c3114"
                  "a5d148168c4506b55cf53984107c396e"
                  "4a3b087eea2ce012fcc1ce319259a3be"
                  "b23eae459cc960816f2d6ba84af45055"
                  "9172b2f683f6223e3a1846427b417a3d"
                  "cae4ca30163749b891686f95532519bd"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "Anime Remux (1080p)";
                    score = 101;
                  }
                ];
                trash_ids = [
                  "064af5f084a0a24458cc8ecd3220f93f"
                ];
              }
            ];
            delete_old_custom_formats = true;
            media_naming = {
              folder = "jellyfin";
              movie = {
                rename = true;
                standard = "anime-jellyfin";
              };
            };
            quality_profiles = [
              {
                min_format_score = 0;
                name = "Anime Remux (1080p)";
                qualities = [
                  {
                    enabled = true;
                    name = "Remux-1080p";
                    qualities = [
                      "Remux-1080p"
                      "Bluray-1080p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "WEB 1080p";
                    qualities = [
                      "WEBRip-1080p"
                      "WEBDL-1080p"
                      "HDTV-1080p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "Bluray-720p";
                  }
                  {
                    enabled = true;
                    name = "WEB 720p";
                    qualities = [
                      "WEBRip-720p"
                      "WEBDL-720p"
                      "HDTV-720p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "Bluray-576p";
                  }
                  {
                    enabled = true;
                    name = "Bluray-480p";
                  }
                  {
                    enabled = true;
                    name = "WEB 480p";
                    qualities = [
                      "WEBRip-480p"
                      "WEBDL-480p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "DVD";
                  }
                  {
                    enabled = true;
                    name = "SDTV";
                  }
                ];
                quality_sort = "top";
                reset_unmatched_scores = {
                  enabled = false;
                };
                score_set = "anime-radarr";
                upgrade = {
                  allowed = true;
                  until_quality = "Remux-1080p";
                  until_score = 10000;
                };
              }
              {
                min_format_score = 0;
                name = "UHD Bluray + WEB";
                qualities = [
                  {
                    enabled = true;
                    name = "Bluray-2160p";
                  }
                  {
                    enabled = true;
                    name = "WEB 2160p";
                    qualities = [
                      "WEBRip-2160p"
                      "WEBDL-2160p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "Bluray-1080p";
                  }
                  {
                    enabled = true;
                    name = "WEB 1080p";
                    qualities = [
                      "WEBRip-1080p"
                      "WEBDL-1080p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "Bluray-720p";
                  }
                ];
                quality_sort = "top";
                reset_unmatched_scores = {
                  enabled = false;
                };
                upgrade = {
                  allowed = true;
                  until_quality = "Bluray-2160p";
                  until_score = 10000;
                };
              }
            ];
            replace_existing_custom_formats = true;
          };
        };
        sonarr = {
          sonarr = {
            api_key = config.sops.placeholder.SONARR_API_KEY;
            base_url = "http://${builtins.head config.virtualisation.oci-containers.compose.mediaserver.containers.sonarr.networking.aliases}:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.sonarr.networking.ports.webui.internal}";
            custom_formats = [
              {
                assign_scores_to = [
                  {
                    name = "Anime";
                  }
                ];
                trash_ids = [
                  "ae575f95ab639ba5d15f663bf019e3e8"
                  "949c16fe0a8147f50ba82cc2df9411c9"
                  "ed7f1e315e000aef424a58517fa48727"
                  "096e406c92baa713da4a72d88030b815"
                  "30feba9da3030c5ed1e0f7d610bcadc4"
                  "545a76b14ddc349b8b185a6344e28b04"
                  "25d2afecab632b1582eaf03b63055f72"
                  "0329044e3d9137b08502a9f84a7e58db"
                  "c81bbfb47fed3d5a3ad027d077f889de"
                  "e0014372773c8f0e1bef8824f00c7dc4"
                  "19180499de5ef2b84b6ec59aae444696"
                  "e6258996055b9fbab7e9cb2f75819294"
                  "58790d4e2fdcd9733aa7ae68ba2bb503"
                  "c27f2ae6a4e82373b0f1da094e2489ad"
                  "d84935abd3f8556dcd51d4f27e22d0a6"
                  "9965a052eb87b0d10313b1cea89eb451"
                  "8a1d0c3d7497e741736761a1da866a2e"
                  "4fd5528a3a8024e6b49f9c67053ea5f3"
                  "29c2a13d091144f63307e4a8ce963a39"
                  "dc262f88d74c651b12e9d90b39f6c753"
                  "b4a1b3d705159cdca36d71e57ca86871"
                  "e3515e519f3b1360cbfc17651944354c"
                  "15a05bc7c1a36e2b57fd628f8977e2fc"
                  "026d5aadd1a6b4e550b134cb6c72b3ca"
                  "d2d7b8a9d39413da5f44054080e028a3"
                  "273bd326df95955e1b6c26527d1df89b"
                  "228b8ee9aa0a609463efca874524a6b8"
                  "0e5833d3af2cc5fa96a0c29cd4477feb"
                  "4fc15eeb8f2f9a749f918217d4234ad8"
                  "b2550eb333d27b75833e25b8c2557b38"
                  "418f50b10f1907201b6cfdf881f467b7"
                  "9c14d194486c4014d422adc64092d794"
                  "07a32f77690263bb9fda1842db7e273f"
                  "3e0b26604165f463f3e8e192261e7284"
                  "89358767a60cc28783cdc3d0be9388a4"
                  "d34870697c9db575f17700212167be23"
                  "d660701077794679fd59e8bdf4ce3a29"
                  "44a8ee6403071dd7b8a3a8dd3fe8cb20"
                  "1284d18e693de8efe0fe7d6b3e0b9170"
                  "a370d974bc7b80374de1d9ba7519760b"
                  "d54cd2bf1326287275b56bccedb72ee2"
                  "7dd31f3dee6d2ef8eeaa156e23c3857e"
                  "4c67ff059210182b59cdd41697b8cb08"
                  "570b03b3145a25011bf073274a407259"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "Anime";
                    score = 10;
                  }
                ];
                trash_ids = [
                  "3bc5f395426614e155e585a2f056cdf1"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "Anime";
                    score = 101;
                  }
                ];
                trash_ids = [
                  "026d5aadd1a6b4e550b134cb6c72b3ca"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "WEB-DL (1080p)";
                    score = 10;
                  }
                ];
                trash_ids = [
                  "3bc5f395426614e155e585a2f056cdf1"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "WEB-DL (1080p)";
                  }
                ];
                trash_ids = [
                  "ae575f95ab639ba5d15f663bf019e3e8"
                  "e6258996055b9fbab7e9cb2f75819294"
                  "58790d4e2fdcd9733aa7ae68ba2bb503"
                  "d84935abd3f8556dcd51d4f27e22d0a6"
                  "d0c516558625b04b363fa6c5c2c7cfd4"
                  "ec8fa7296b64e8cd390a1600981f3923"
                  "eb3d5cc0a2be0db205fb823640db6a3c"
                  "44e7c4de10ae50265753082e5dc76047"
                  "85c61753df5da1fb2aab6f2a47426b09"
                  "9c11cd3f07101cdba90a2d81cf0e56b4"
                  "e2315f990da2e2cbfc9fa5b7a6fcfe48"
                  "fbcb31d8dabd2a319072b84fc0b7249c"
                  "15a05bc7c1a36e2b57fd628f8977e2fc"
                  "32b367365729d530ca1c124a0b180c64"
                  "82d40da2bc6923f41e14394075dd4b03"
                  "e1a997ddb54e3ecbfe06341ad323c458"
                  "06d66ab109d4d2eddb2794d21526d140"
                  "1b3994c551cbb92a2c781af061f4ab44"
                  "f67c9ca88f463a48346062e8ad07713f"
                  "89358767a60cc28783cdc3d0be9388a4"
                  "81d1fbf600e2540cee87f3a23f9d3c1c"
                  "a880d6abc21e7c16884f3ae393f84179"
                  "3ac5d84fce98bab1b531393e9c82f467"
                  "d660701077794679fd59e8bdf4ce3a29"
                  "d34870697c9db575f17700212167be23"
                  "1656adc6d7bb2c8cca6acfb6592db421"
                  "c67a75ae4a1715f2bb4d492755ba4195"
                  "1efe8da11bfd74fbbcd4d8117ddb9213"
                  "77a7b25585c18af08f60b1547bb9b4fb"
                  "4e9a630db98d5391aec1368a0256e2fe"
                  "36b72f59f4ea20aad9316f475f2d9fbb"
                  "7a235133c87f7da4c8cccceca7e3c7a6"
                  "f6cce30f1733d5c8194222a7507909bb"
                  "0ac24a2a68a9700bcb7eeca8e5cd644c"
                  "b2b980877494b560443631eb1f473867"
                  "c30d2958827d1867c73318a5a2957eb1"
                  "ae58039e1319178e6be73caab5c42166"
                  "5d2317d99af813b6529c7ebf01c83533"
                  "fb1a91cdc0f26f7ca0696e0e95274645"
                  "7be9c0572d8cd4f81785dacf7e85985e"
                  "7be9c0572d8cd4f81785dacf7e85985e"
                  "0e99e7cc719a8a73b2668c3a0c3fe10c"
                  "fcc09418f67ccaddcf3b641a22c5cfd7"
                  "bbcaf03147de0f73be2be4a9078dfa03"
                  "07a32f77690263bb9fda1842db7e273f"
                ];
              }
              {
                assign_scores_to = [
                  {
                    name = "WEB-DL (1080p)";
                    score = 101;
                  }
                ];
                trash_ids = [
                  "026d5aadd1a6b4e550b134cb6c72b3ca"
                ];
              }
            ];
            delete_old_custom_formats = true;
            media_naming = {
              episodes = {
                anime = "default";
                daily = "default";
                rename = true;
                standard = "default";
              };
              season = "default";
              series = "jellyfin";
            };
            quality_profiles = [
              {
                min_format_score = 0;
                name = "Anime";
                qualities = [
                  {
                    enabled = true;
                    name = "Bluray 1080p";
                    qualities = [
                      "Bluray-1080p Remux"
                      "Bluray-1080p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "WEB 1080p";
                    qualities = [
                      "WEBDL-1080p"
                      "WEBRip-1080p"
                      "HDTV-1080p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "Bluray-720p";
                  }
                  {
                    enabled = true;
                    name = "WEB 720p";
                    qualities = [
                      "WEBDL-720p"
                      "WEBRip-720p"
                      "HDTV-720p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "Bluray-480p";
                  }
                  {
                    enabled = true;
                    name = "DVD";
                  }
                  {
                    enabled = true;
                    name = "SDTV";
                  }
                ];
                quality_sort = "top";
                reset_unmatched_scores = {
                  enabled = false;
                };
                score_set = "anime-sonarr";
                upgrade = {
                  allowed = true;
                  until_quality = "Bluray 1080p";
                  until_score = 10000;
                };
              }
              {
                min_format_score = 0;
                name = "WEB-DL (1080p)";
                qualities = [
                  {
                    enabled = true;
                    name = "Bluray-1080p";
                    qualities = [
                      "Bluray-1080p Remux"
                      "Bluray-1080p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "WEBDL-1080p";
                    qualities = [
                      "WEBDL-1080p"
                      "WEBRip-1080p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "HDTV-1080p";
                  }
                  {
                    enabled = true;
                    name = "Bluray-720p";
                  }
                  {
                    enabled = true;
                    name = "WEBDL-720p";
                    qualities = [
                      "WEBDL-720p"
                      "WEBRip-720p"
                    ];
                  }
                  {
                    enabled = true;
                    name = "HDTV-720p";
                  }
                ];
                quality_sort = "top";
                reset_unmatched_scores = {
                  enabled = false;
                };
                upgrade = {
                  allowed = true;
                  until_quality = "Bluray-1080p";
                  until_score = 10000;
                };
              }
            ];
            replace_existing_custom_formats = true;
          };
        };
      };
    };
    RECYCLARR_SETTINGS = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      restartUnits = [config.virtualisation.oci-containers.compose.mediaserver.containers.recyclarr.unitName];
      content = lib.generators.toYAML {} {
        notifications = {
          apprise = {
              mode = "stateful";
              base_url = "http://apprise:8000";
              key = config.sops.placeholder.RECYCLARR_APPRISE_KEY;
          };
        };
      };
    };
  };
}