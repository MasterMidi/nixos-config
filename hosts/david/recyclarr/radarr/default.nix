{...}: let
  qualityProfiles = import ./qualityProfiles.nix;

  # Function to convert the set of profiles into a list
  profilesToList = set: builtins.attrValues set;
in {
  default = {
    base_url = "http://192.168.50.2:9030";
    api_key = "51732014769e475a9455c1f5cd8f18d1";
    delete_old_custom_formats = true;
    replace_existing_custom_formats = true;
    media_naming = {
      folder = "jellyfin";
      movie = {
        rename = true;
        standard = "anime-jellyfin";
      };
    };
    # quality_definition = {}; # Set this later
    quality_profiles = profilesToList qualityProfiles;
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
        quality_profiles = [{name = "Remux + WEB (2160p)";} {name = "Remux + WEB (1080p)";} {name = "Legacy";} {name = qualityProfiles.animeRemux1080p.name;}];
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

      ###### ANIME STUFFF

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
        quality_profiles = [{name = qualityProfiles.animeRemux1080p.name;} {name = qualityProfiles.animeRemux2160p.name;}];
      }
      {
        trash_ids = ["064af5f084a0a24458cc8ecd3220f93f"];
        quality_profiles = [
          {
            name = qualityProfiles.animeRemux1080p.name;
            score = 50;
          }
          {
            name = qualityProfiles.animeRemux2160p.name;
            score = 50;
          }
        ];
      }
      {
        trash_ids = ["3a3ff47579026e76d6504ebea39390de"];
        quality_profiles = [
          {
            name = qualityProfiles.animeRemux1080p.name;
            score = 1050;
          }
          {
            name = qualityProfiles.animeRemux2160p.name;
            score = 1050;
          }
        ];
      }
      {
        trash_ids = ["9f98181fe5a3fbeb0cc29340da2a468a"];
        quality_profiles = [
          {
            name = qualityProfiles.animeRemux1080p.name;
            score = 1000;
          }
          {
            name = qualityProfiles.animeRemux2160p.name;
            score = 1000;
          }
        ];
      }
      {
        trash_ids = ["8baaf0b3142bf4d94c42a724f034e27a"];
        quality_profiles = [
          {
            name = qualityProfiles.animeRemux1080p.name;
            score = 950;
          }
          {
            name = qualityProfiles.animeRemux2160p.name;
            score = 950;
          }
        ];
      }
      {
        trash_ids = ["c20f169ef63c5f40c2def54abaf4438e"];
        quality_profiles = [
          {
            name = qualityProfiles.animeRemux1080p.name;
            score = 350;
          }
          {
            name = qualityProfiles.animeRemux2160p.name;
            score = 350;
          }
        ];
      }
      {
        trash_ids = ["403816d65392c79236dcb6dd591aeda4"];
        quality_profiles = [
          {
            name = qualityProfiles.animeRemux1080p.name;
            score = 250;
          }
          {
            name = qualityProfiles.animeRemux2160p.name;
            score = 250;
          }
        ];
      }
      {
        trash_ids = ["af94e0fe497124d1f9ce732069ec8c3b"];
        quality_profiles = [
          {
            name = qualityProfiles.animeRemux1080p.name;
            score = 150;
          }
          {
            name = qualityProfiles.animeRemux2160p.name;
            score = 150;
          }
        ];
      }
    ];
  };
}
