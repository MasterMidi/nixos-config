{...}: {
  default = rec {
    baseUrl = "http://radarr:7878";
    apiKey = "51732014769e475a9455c1f5cd8f18d1";
    deleteOldCustomFormats = true;
    replaceExistingCustomFormats = true;
    mediaNaming = {
      folder = "jellyfin";
      movie = {
        rename = true;
        standard = "anime-jellyfin";
      };
    };
    # quality_definition = {}; # Set this later
    qualityProfiles = import ./qualityProfiles.nix;
    customFormats = 
    # UHD Bluray + WEB
    [
      {
        trashIds = [
        # HDR formats
          "c53085ddbd027d9624b320627748612f" # DV HDR10+
          "e23edd2482476e595fb990b12e7c609c" # DV HDR10
          "58d6a88f13e2db7f5059c41047876f00" # DV
          "55d53828b9d81cbe20b02efd00aa0efd" # DV HLG
          "a3e19f8f627608af0211acd02bf89735" # DV SDR
          "b974a6cd08c1066250f1f177d7aa1225" # HDR10+
          "dfb86d5941bc9075d6af23b09c2aeecd" # HDR10
          "e61e28db95d22bedcadf030b8f156d96" # HDR
          "2a4d9069cc1fe3242ff9bdaebed239bb" # HDR (undefined)
          "08d6d8834ad9ec87b1dc7ec8148e7a1f" # PQ
          "9364dd386c9b4a1100dde8264690add7" # HLG
          "923b6abef9b17f937fab56cfcf89e1f1" # DV (WEBDL)
        # HQ Release groups
          "4d74ac4c4db0b64bff6ce0cffef99bf0" # UHD Bluray Tier 01
          "a58f517a70193f8e578056642178419d" # UHD Bluray Tier 02
          "e71939fae578037e7aed3ee219bbe7c1" # UHD Bluray Tier 03
          "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01 
          "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
          "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03
        # Miscellaneous
          "e7718d7a3ce595f289bfee26adc178f5" # Repack/Proper
          "ae43b294509409a6a13919dedd4764c4" # Repack2
          "5caaaa1c08c1742aa4342d8c4cc463f2" # Repack3
        # Unwanted
          "ed38b889b31be83fda192888e2286d83" # BR-DISK
          "90a6f9a284dff5103f6346090e6280c8" # LQ
          "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
          "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
          "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
          "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
          "0a3f082873eb454bde444150b70253cc" # Extras
          "cae4ca30163749b891686f95532519bd" # AV1
          "9172b2f683f6223e3a1846427b417a3d" # VOSTFR
        # Streaming services
          "b3b3a6ac74ecbd56bcdbefa4799fb9df" # AMZN
          "40e9380490e748672c2522eaaeb692f7" # ATVP
          "cc5e51a9e85a6296ceefe097a77f12f4" # BCORE
          "16622a6911d1ab5d5b8b713d5b0036d4" # CRiT
          "84272245b2988854bfb76a16e60baea5" # DSNP
          "509e5f41146e278f9eab1ddaceb34515" # HBO
          "5763d1b0ce84aff3b21038eea8e9b8ad" # HMAX
          "526d445d4c16214309f0fd2b3be18a89" # Hulu
          "e0ec9672be6cac914ffad34a6b077209" # iT
          "6a061313d22e51e0f25b7cd4dc065233" # MAX
          "2a6039655313bf5dab1e43523b62c374" # MA
          "170b1d363bd8516fbf3a3eb05d4faff6" # NF
          "e36a0ba1bc902b26ee40818a1d59b8bd" # PMTP
          "c9fd353f8f5f1baf56dc601c4cb29920" # PCOK
          "c2863d2a50c9acad1fb50e53ece60817" # STAN
          # Miscellaneous (optional)
          "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
          "90cedc1fea7ea5d11298bebd3d1d3223" # EVO (no WEBDL)
          "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup
          "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
          "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
          "f537cf427b64c38c8e36298f657e4828" # Scene
          # Movie versions
          "570bc9ebecd92723d2d21500f4be314c" # Remaster
          "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
          "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
          "9d27d9d2181838f76dee150882bdc58c" # Masters of Cinema
          "db9b4c4b53d312a3ca5f1378f6440fc9" # Vinegar Syndrome
          "957d0f44b592285f26449575e8b1167e" # Special Edition
          "eecf3a857724171f968a66cb5719e152" # IMAX
          "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
        ];
        assignScoresTo = [{name = "UHD Bluray + WEB";}];
      }
      {
        trashIds = [
          "064af5f084a0a24458cc8ecd3220f93f" # Uncensored
        ];
        assignScoresTo = [
          {
            name = "UHD Bluray + WEB";
            score = 101;
          }
        ];
      }
    ]
    # Anime remux 1080p
    ++ [
      {
        trashIds = [
          "fb3ccc5d5cc8f77c9055d4cb4561dded" # Anime BD Tier 01 (Top SeaDex Muxers)
          "66926c8fa9312bc74ab71bf69aae4f4a" # Anime BD Tier 02 (SeaDex Muxers)
          "fa857662bad28d5ff21a6e611869a0ff" # Anime BD Tier 03 (SeaDex Muxers)
          "f262f1299d99b1a2263375e8fa2ddbb3" # Anime BD Tier 04 (SeaDex Muxers)
          "ca864ed93c7b431150cc6748dc34875d" # Anime BD Tier 05 (Remuxes)
          "9dce189b960fddf47891b7484ee886ca" # Anime BD Tier 06 (FanSubs)
          "1ef101b3a82646b40e0cab7fc92cd896" # Anime BD Tier 07 (P2P/Scene)
          "6115ccd6640b978234cc47f2c1f2cadc" # Anime BD Tier 08 (Mini Encodes)
          "8167cffba4febfb9a6988ef24f274e7e" # Anime Web Tier 01 (Muxers)
          "8526c54e36b4962d340fce52ef030e76" # Anime Web Tier 02 (Top FanSubs)
          "de41e72708d2c856fa261094c85e965d" # Anime Web Tier 03 (Official Subs)
          "9edaeee9ea3bcd585da9b7c0ac3fc54f" # Anime Web Tier 04 (Official Subs)
          "22d953bbe897857b517928f3652b8dd3" # Anime Web Tier 05 (FanSubs)
          "a786fbc0eae05afe3bb51aee3c83a9d4" # Anime Web Tier 06 (FanSubs)
          "3a3ff47579026e76d6504ebea39390de" # Remux Tier 01
          "9f98181fe5a3fbeb0cc29340da2a468a" # Remux Tier 02
          "8baaf0b3142bf4d94c42a724f034e27a" # Remux Tier 03
          "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
          "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
          "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03
          "06b6542a47037d1e33b15aa3677c2365" # Anime Raws
          "b0fdc5897f68c9a68c70c25169f77447" # Anime LQ Groups
          "c259005cbaeb5ab44c06eddb4751e70c" # v0
          "5f400539421b8fcf71d51e6384434573" # v1
          "3df5e6dfef4b09bb6002f732bed5b774" # v2
          "db92c27ba606996b146b57fbe6d09186" # v3
          "d4e5e842fad129a3c097bdb2d20d31a0" # v4
          "60f6d50cbd3cfc3e9a8c00e3a30c3114" # VRV
          "a5d148168c4506b55cf53984107c396e" # 10bit
          "4a3b087eea2ce012fcc1ce319259a3be" # Anime Dual Audio
          "b23eae459cc960816f2d6ba84af45055" # Dubs Only
          "9172b2f683f6223e3a1846427b417a3d" # VOSTFR
          "cae4ca30163749b891686f95532519bd" # AV1
        ];
        assignScoresTo = [{name = "Anime Remux (1080p)";}];
      }
      {
        trashIds = [
          "064af5f084a0a24458cc8ecd3220f93f" # Uncensored
        ];
        assignScoresTo = [
          {
            name = "Anime Remux (1080p)";
            score = 101;
          }
        ];
      }
    ];
  };
}
