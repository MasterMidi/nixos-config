{...}: {
  services.recyclarr = {
    enable = true;
    settings = {};
    config = {
      # <name> = {}; the service type
      sonarr = {
        main = {
          base_url = "http://192.168.50.2:9040";
          api_key = "c5783cdc82d244e6b138be2988397813";
          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;
          quality_profiles = [
            {
              name = "Anime";
              reset_unmatched_scores = {
                enabled = true;
                except = [];
              };
              upgrade = {
                allowed = true;
                until_quality = "Bluray 1080p";
                until_score = 10000;
              };
              min_format_score = 10;
              score_set = "sqp-1-1080p"; # https://recyclarr.dev/wiki/yaml/config-reference/quality-profiles/#score-set
              quality_sort = "top";
              qualities = [
                {
                  name = "Bluray 1080p";
                  enabled = false;
                  qualities = [
                    "Bluray-1080p"
                    "Bluray-1080p Remux"
                  ];
                }
                {
                  name = "WEB 1080p";
                  enabled = false;
                  qualities = [
                    "WEBDL-1080p"
                    "WEBRip-1080p"
                    "HDTV-1080p"
                  ];
                }
              ];
            }
          ];
          custom_formats = [
            {
              # Anime Release Groups
              trash_ids = [
                "949c16fe0a8147f50ba82cc2df9411c9" # Anime BD Tier 01 (Top SeaDex Muxers)
                "ed7f1e315e000aef424a58517fa48727" # Anime BD Tier 02 (SeaDex Muxers)
                "096e406c92baa713da4a72d88030b815" # Anime BD Tier 03 (SeaDex Muxers)
                "30feba9da3030c5ed1e0f7d610bcadc4" # Anime BD Tier 04 (SeaDex Muxers)
                "545a76b14ddc349b8b185a6344e28b04" # Anime BD Tier 05 (Reuxes)
                "25d2afecab632b1582eaf03b63055f72" # Anime BD Tier 06 (FanSubs)
                "0329044e3d9137b08502a9f84a7e58db" # Anime BD Tier 07 (P2P/Scene)
                "c81bbfb47fed3d5a3ad027d077f889de" # Anime BD Tier 08 (Mini Encodes)
                "e0014372773c8f0e1bef8824f00c7dc4" # Anime Web Tier 01 (Muxers)
                "19180499de5ef2b84b6ec59aae444696" # Anime Web Tier 02 (Top FanSubs)
                "c27f2ae6a4e82373b0f1da094e2489ad" # Anime Web Tier 03 (Official Subs)
                "4fd5528a3a8024e6b49f9c67053ea5f3" # Anime Web Tier 04 (Official Subs)
                "29c2a13d091144f63307e4a8ce963a39" # Anime Web Tier 05 (FanSubs)
                "dc262f88d74c651b12e9d90b39f6c753" # Anime Web Tier 06 (FanSubs)
                "b4a1b3d705159cdca36d71e57ca86871" # Anime Raws
                "e3515e519f3b1360cbfc17651944354c" # Anime LQ Groups
              ];
              quality_profiles = [{name = "Anime";}];
            }
            {
              # Anime Audio
              trash_ids = [
                "418f50b10f1907201b6cfdf881f467b7" # Anime Dual Audio
                "9c14d194486c4014d422adc64092d794" # dubs only
                "07a32f77690263bb9fda1842db7e273f" # VOSTFR
              ];
              quality_profiles = [{name = "Anime";}];
            }
            {
              # Anime Versions
              trash_ids = [
                "4fc15eeb8f2f9a749f918217d4234ad8" # v4
                "0e5833d3af2cc5fa96a0c29cd4477feb" # v3
                "228b8ee9aa0a609463efca874524a6b8" # v2
                "273bd326df95955e1b6c26527d1df89b" # v1
                "d2d7b8a9d39413da5f44054080e028a3" # v0
              ];
              quality_profiles = [{name = "Anime";}];
            }
            {
              # Anime Streaming Services
              trash_ids = [
                "3e0b26604165f463f3e8e192261e7284" # Crunchyroll
                "44a8ee6403071dd7b8a3a8dd3fe8cb20" # VRV
                "1284d18e693de8efe0fe7d6b3e0b9170" # FUNi
                "4c67ff059210182b59cdd41697b8cb08" # BiliBili
                "570b03b3145a25011bf073274a407259" # HIDIVE
              ];
              quality_profiles = [{name = "Anime";}];
            }
            {
              # Anime DSNP
              trash_ids = ["89358767a60cc28783cdc3d0be9388a4"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 5;
                }
              ];
            }
            {
              # Anime NF
              trash_ids = ["d34870697c9db575f17700212167be23"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 4;
                }
              ];
            }
            {
              # Anime AMZN
              trash_ids = ["d660701077794679fd59e8bdf4ce3a29"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 3;
                }
              ];
            }
            {
              # Anime ADN
              trash_ids = ["d54cd2bf1326287275b56bccedb72ee2"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 1;
                }
              ];
            }
            {
              # Anime Remux Tier 01
              trash_ids = ["9965a052eb87b0d10313b1cea89eb451"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 1050;
                }
              ];
            }
            {
              # Anime Remux Tier 02
              trash_ids = ["8a1d0c3d7497e741736761a1da866a2e"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 1000;
                }
              ];
            }
            {
              # Anime WEB Tier 01
              trash_ids = ["e6258996055b9fbab7e9cb2f75819294"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 350;
                }
              ];
            }
            {
              # Anime WEB Tier 02
              trash_ids = ["58790d4e2fdcd9733aa7ae68ba2bb503"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 150;
                }
              ];
            }
            {
              # Anime WEB Tier 03
              trash_ids = ["d84935abd3f8556dcd51d4f27e22d0a6"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 150;
                }
              ];
            }
            {
              # Uncensored
              trash_ids = ["026d5aadd1a6b4e550b134cb6c72b3ca"];
              quality_profiles = [
                {
                  name = "Anime";
                  score = 101;
                }
                {
                  name = "WEB-DL (1080p)";
                  score = 101;
                }
              ];
            }
            {
              # Misc
              trash_ids = [
                "b2550eb333d27b75833e25b8c2557b38" # 10bit
                "3bc5f395426614e155e585a2f056cdf1" # Season pack
                "ec8fa7296b64e8cd390a1600981f3923" # Repack/Proper
                "eb3d5cc0a2be0db205fb823640db6a3c" # Repack v2
                "44e7c4de10ae50265753082e5dc76047" # Repack v3
              ];
              quality_profiles = [{name = "Anime";} {name = "WEB-DL (1080p)";}];
            }
            {
              # Codecs
              trash_ids = [
                "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
                # "9b64dff695c2115facf1b6ea59c9bd07" # x265 (no HDR/DV)
              ];
              quality_profiles = [{name = "Anime";} {name = "WEB-DL (1080p)";}];
            }
            {
              # Unwanted
              trash_ids = [
                "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
                "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
              ];
              quality_profiles = [{name = "Anime";} {name = "WEB-DL (1080p)";}];
            }
            {
              # Streaming Services
              trash_ids = [
                "f67c9ca88f463a48346062e8ad07713f" # ATVP
                "89358767a60cc28783cdc3d0be9388a4" # DSNP
                "81d1fbf600e2540cee87f3a23f9d3c1c" # MAX
                "a880d6abc21e7c16884f3ae393f84179" # HMAX
                "3ac5d84fce98bab1b531393e9c82f467" # QIBI
                "d660701077794679fd59e8bdf4ce3a29" # AMZN
                "d34870697c9db575f17700212167be23" # NF
                "1656adc6d7bb2c8cca6acfb6592db421" # PCOK
                "c67a75ae4a1715f2bb4d492755ba4195" # PMTP
                "1efe8da11bfd74fbbcd4d8117ddb9213" # STAN
                "77a7b25585c18af08f60b1547bb9b4fb" # CC
                "4e9a630db98d5391aec1368a0256e2fe" # CRAV
                "36b72f59f4ea20aad9316f475f2d9fbb" # DCU
                "7a235133c87f7da4c8cccceca7e3c7a6" # HBO
                "f6cce30f1733d5c8194222a7507909bb" # HULU
                "0ac24a2a68a9700bcb7eeca8e5cd644c" # iT
                "b2b980877494b560443631eb1f473867" # NLZ
                "c30d2958827d1867c73318a5a2957eb1" # RED
                "ae58039e1319178e6be73caab5c42166" # SHO
                "5d2317d99af813b6529c7ebf01c83533" # VDL
                "fb1a91cdc0f26f7ca0696e0e95274645" # OViD
                "7be9c0572d8cd4f81785dacf7e85985e" # FOD
                "7be9c0572d8cd4f81785dacf7e85985e" # TVer
                "0e99e7cc719a8a73b2668c3a0c3fe10c" # U-NEXT
                "fcc09418f67ccaddcf3b641a22c5cfd7" # ALL4
                "bbcaf03147de0f73be2be4a9078dfa03" # 4OD
              ];
              quality_profiles = [{name = "WEB-DL (1080p)";}];
            }
            {
              # HQ Source Groups
              trash_ids = [
                "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
                "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
                "d0c516558625b04b363fa6c5c2c7cfd4" # WEB Scene
              ];
              quality_profiles = [{name = "WEB-DL (1080p)";}];
            }
          ];
        };
      };
      radarr = {
        anime = {
          base_url = "http://192.168.50.2:9031";
          api_key = "6db4d4c7ec4049b487c293712576c2f0";
          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;
          custom_formats = [
            {
              trash_ids = [
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
                "06b6542a47037d1e33b15aa3677c2365"
                "b0fdc5897f68c9a68c70c25169f77447"
                "a5d148168c4506b55cf53984107c396e"
                "cae4ca30163749b891686f95532519bd"
                "839bea857ed2c0a8e084f3cbdbd65ecb"
                "4a3b087eea2ce012fcc1ce319259a3be"
                "b23eae459cc960816f2d6ba84af45055"
                "9172b2f683f6223e3a1846427b417a3d"
                "d4e5e842fad129a3c097bdb2d20d31a0"
                "db92c27ba606996b146b57fbe6d09186"
                "3df5e6dfef4b09bb6002f732bed5b774"
                "5f400539421b8fcf71d51e6384434573"
                "c259005cbaeb5ab44c06eddb4751e70c"
              ];
              quality_profiles = [{name = "Anime Remux (1080p)";} {name = "Anime Remux (2160p)";}];
            }
            {
              trash_ids = ["064af5f084a0a24458cc8ecd3220f93f"];
              quality_profiles = [
                {
                  name = "Anime Remux (1080p)";
                  score = 50;
                }
                {
                  name = "Anime Remux (2160p)";
                  score = 50;
                }
              ];
            }
            {
              trash_ids = ["3a3ff47579026e76d6504ebea39390de"];
              quality_profiles = [
                {
                  name = "Anime Remux (1080p)";
                  score = 1050;
                }
                {
                  name = "Anime Remux (2160p)";
                  score = 1050;
                }
              ];
            }
            {
              trash_ids = ["9f98181fe5a3fbeb0cc29340da2a468a"];
              quality_profiles = [
                {
                  name = "Anime Remux (1080p)";
                  score = 1000;
                }
                {
                  name = "Anime Remux (2160p)";
                  score = 1000;
                }
              ];
            }
            {
              trash_ids = ["8baaf0b3142bf4d94c42a724f034e27a"];
              quality_profiles = [
                {
                  name = "Anime Remux (1080p)";
                  score = 950;
                }
                {
                  name = "Anime Remux (2160p)";
                  score = 950;
                }
              ];
            }
            {
              trash_ids = ["c20f169ef63c5f40c2def54abaf4438e"];
              quality_profiles = [
                {
                  name = "Anime Remux (1080p)";
                  score = 350;
                }
                {
                  name = "Anime Remux (2160p)";
                  score = 350;
                }
              ];
            }
            {
              trash_ids = ["403816d65392c79236dcb6dd591aeda4"];
              quality_profiles = [
                {
                  name = "Anime Remux (1080p)";
                  score = 250;
                }
                {
                  name = "Anime Remux (2160p)";
                  score = 250;
                }
              ];
            }
            {
              trash_ids = ["af94e0fe497124d1f9ce732069ec8c3b"];
              quality_profiles = [
                {
                  name = "Anime Remux (1080p)";
                  score = 150;
                }
                {
                  name = "Anime Remux (2160p)";
                  score = 150;
                }
              ];
            }
          ];
        };
        default = {
          base_url = "http://192.168.50.2:9030";
          api_key = "51732014769e475a9455c1f5cd8f18d1";
          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;
          custom_formats = [
            {
              trash_ids = [
                "e23edd2482476e595fb990b12e7c609c"
                "58d6a88f13e2db7f5059c41047876f00"
                "55d53828b9d81cbe20b02efd00aa0efd"
                "a3e19f8f627608af0211acd02bf89735"
                "b17886cb4158d9fea189859409975758"
                "b974a6cd08c1066250f1f177d7aa1225"
                "dfb86d5941bc9075d6af23b09c2aeecd"
                "e61e28db95d22bedcadf030b8f156d96"
                "2a4d9069cc1fe3242ff9bdaebed239bb"
                "08d6d8834ad9ec87b1dc7ec8148e7a1f"
                "9364dd386c9b4a1100dde8264690add7"
                "923b6abef9b17f937fab56cfcf89e1f1"
              ];
              quality_profiles = [{name = "Remux + WEB (2160p)";} {name = "Remux + WEB (1080p)";} {name = "Legacy";}];
            }
            {
              trash_ids = [
                "0f12c086e289cf966fa5948eac571f44"
                "570bc9ebecd92723d2d21500f4be314c"
                "eca37840c13c6ef2dd0262b141a5482f"
                "e0c07d59beb37348e975a930d5e50319"
                "9d27d9d2181838f76dee150882bdc58c"
                "db9b4c4b53d312a3ca5f1378f6440fc9"
                "957d0f44b592285f26449575e8b1167e"
                "eecf3a857724171f968a66cb5719e152"
                "9f6cbff8cfe4ebbc1bde14c7b7bec0de"
              ];
              quality_profiles = [{name = "Remux + WEB (2160p)";} {name = "Remux + WEB (1080p)";} {name = "Legacy";}];
            }
            {
              trash_ids = [
                "4d74ac4c4db0b64bff6ce0cffef99bf0"
                "a58f517a70193f8e578056642178419d"
                "e71939fae578037e7aed3ee219bbe7c1"
              ];
              quality_profiles = [{name = "Remux + WEB (2160p)";}];
            }
            {
              trash_ids = [
                "ed27ebfef2f323e964fb1f61391bcb35"
                "c20c8647f2746a1f4c4262b0fbbeeeae"
                "5608c71bcebba0a5e666223bae8c9227"
              ];
              quality_profiles = [{name = "Remux + WEB (1080p)";} {name = "Legacy";}];
            }
            {
              trash_ids = [
                "3a3ff47579026e76d6504ebea39390de"
                "9f98181fe5a3fbeb0cc29340da2a468a"
                "8baaf0b3142bf4d94c42a724f034e27a"
                "c20f169ef63c5f40c2def54abaf4438e"
                "403816d65392c79236dcb6dd591aeda4"
                "af94e0fe497124d1f9ce732069ec8c3b"
              ];
              quality_profiles = [{name = "Remux + WEB (2160p)";} {name = "Remux + WEB (1080p)";} {name = "Legacy";}];
            }
            {
              trash_ids = [
                "b3b3a6ac74ecbd56bcdbefa4799fb9df"
                "40e9380490e748672c2522eaaeb692f7"
                "cc5e51a9e85a6296ceefe097a77f12f4"
                "f6ff65b3f4b464a79dcc75950fe20382"
                "16622a6911d1ab5d5b8b713d5b0036d4"
                "84272245b2988854bfb76a16e60baea5"
                "509e5f41146e278f9eab1ddaceb34515"
                "5763d1b0ce84aff3b21038eea8e9b8ad"
                "6a061313d22e51e0f25b7cd4dc065233"
                "526d445d4c16214309f0fd2b3be18a89"
                "2a6039655313bf5dab1e43523b62c374"
                "170b1d363bd8516fbf3a3eb05d4faff6"
                "bf7e73dd1d85b12cc527dc619761c840"
                "c9fd353f8f5f1baf56dc601c4cb29920"
                "e36a0ba1bc902b26ee40818a1d59b8bd"
                "c2863d2a50c9acad1fb50e53ece60817"
                "fbca986396c5e695ef7b2def3c755d01"
                "917d1f2c845b2b466036b0cc2d7c72a3"
                "f1b0bae9bc222dab32c1b38b5a7a1088"
                "279bda7434fd9075786de274e6c3c202"
              ];
              quality_profiles = [{name = "Remux + WEB (2160p)";} {name = "Remux + WEB (1080p)";} {name = "Legacy";}];
            }
            {
              trash_ids = [
                "e7718d7a3ce595f289bfee26adc178f5"
                "ae43b294509409a6a13919dedd4764c4"
              ];
              quality_profiles = [{name = "Remux + WEB (2160p)";} {name = "Remux + WEB (1080p)";} {name = "Legacy";}];
            }
            {
              trash_ids = [
                "ed38b889b31be83fda192888e2286d83"
                "90a6f9a284dff5103f6346090e6280c8"
                "e204b80c87be9497a8a6eaff48f72905"
                "b8cd450cbfa689c0259a01d9e29ba3d6"
                "bfd8eb01832d646a0a89c4deb46f8564"
                "0a3f082873eb454bde444150b70253cc"
              ];
              quality_profiles = [{name = "Remux + WEB (2160p)";} {name = "Remux + WEB (1080p)";} {name = "Legacy";}];
            }
          ];
        };
      };
    };
  };
}
