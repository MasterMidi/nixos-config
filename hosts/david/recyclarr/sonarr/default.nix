{...}: let
  qualityProfiles = import ./qualityProfiles.nix;

  # Function to convert the set of profiles into a list
  profilesToList = set: builtins.attrValues set;
in {
  main = {
    base_url = "http://jason.local:9040";
    api_key = "c5783cdc82d244e6b138be2988397813";
    delete_old_custom_formats = true;
    replace_existing_custom_formats = true;
    media_naming = {
      series = "jellyfin";
      season = "default";
      episodes = {
        rename = true;
        standard = "default";
        daily = "default";
        anime = "default";
      };
    };
    quality_profiles = profilesToList qualityProfiles;
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
        quality_profiles = [{name = qualityProfiles.anime.name;}];
      }
      {
        # Anime Audio
        trash_ids = [
          "418f50b10f1907201b6cfdf881f467b7" # Anime Dual Audio
          "9c14d194486c4014d422adc64092d794" # dubs only
          "07a32f77690263bb9fda1842db7e273f" # VOSTFR
        ];
        quality_profiles = [{name = qualityProfiles.anime.name;}];
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
        quality_profiles = [{name = qualityProfiles.anime.name;}];
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
        quality_profiles = [{name = qualityProfiles.anime.name;}];
      }
      {
        # Anime DSNP
        trash_ids = ["89358767a60cc28783cdc3d0be9388a4"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 5;
          }
        ];
      }
      {
        # Anime NF
        trash_ids = ["d34870697c9db575f17700212167be23"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 4;
          }
        ];
      }
      {
        # Anime AMZN
        trash_ids = ["d660701077794679fd59e8bdf4ce3a29"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 3;
          }
        ];
      }
      {
        # Anime ADN
        trash_ids = ["d54cd2bf1326287275b56bccedb72ee2"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 1;
          }
        ];
      }
      {
        # Anime Remux Tier 01
        trash_ids = ["9965a052eb87b0d10313b1cea89eb451"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 1050;
          }
        ];
      }
      {
        # Anime Remux Tier 02
        trash_ids = ["8a1d0c3d7497e741736761a1da866a2e"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 1000;
          }
        ];
      }
      {
        # Anime WEB Tier 01
        trash_ids = ["e6258996055b9fbab7e9cb2f75819294"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 350;
          }
        ];
      }
      {
        # Anime WEB Tier 02
        trash_ids = ["58790d4e2fdcd9733aa7ae68ba2bb503"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 150;
          }
        ];
      }
      {
        # Anime WEB Tier 03
        trash_ids = ["d84935abd3f8556dcd51d4f27e22d0a6"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 150;
          }
        ];
      }
      {
        # Uncensored
        trash_ids = ["026d5aadd1a6b4e550b134cb6c72b3ca"];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = 101;
          }
          {
            name = qualityProfiles.webdl.name;
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
        quality_profiles = [{name = qualityProfiles.anime.name;} {name = qualityProfiles.webdl.name;}];
      }
      {
        # Codecs
        trash_ids = [
          "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
        ];
        quality_profiles = [
          {
            name = qualityProfiles.anime.name;
            score = -10;
          }
          {
            name = qualityProfiles.webdl.name;
            score = -10;
          }
        ];
      }
      {
        # Unwanted
        trash_ids = [
          "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
          "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
          "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
          "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
        ];
        quality_profiles = [{name = qualityProfiles.anime.name;} {name = qualityProfiles.webdl.name;}];
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
        quality_profiles = [{name = qualityProfiles.webdl.name;}];
      }
      {
        # HQ Source Groups
        trash_ids = [
          "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
          "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
          "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
          "d0c516558625b04b363fa6c5c2c7cfd4" # WEB Scene
        ];
        quality_profiles = [{name = qualityProfiles.webdl.name;}];
      }
    ];
  };
}
