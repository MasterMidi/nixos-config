let
  qualities = import ../qualities.nix;
in {
  animeRemux1080p = {
    name = "Anime Remux (1080p)";
    scoreSet = "anime-radarr";
    upgrade = {
      allowed = true;
      untilQuality = qualities.remux1080p;
      untilScore = 10000;
    };
    minFormatScore = 0;
    qualities = [
      {
        name = qualities.remux1080p;
        qualities = [
          qualities.remux1080p
          qualities.bluray1080p
        ];
      }
      {
        name = "WEB 1080p";
        qualities = [
          qualities.webRip1080p
          qualities.webDl1080p
          qualities.hdtv1080p
        ];
      }
      {
        name = qualities.bluray720p;
      }
      {
        name = "WEB 720p";
        qualities = [
          qualities.webRip720p
          qualities.webDl720p
          qualities.hdtv720p
        ];
      }
      {
        name = qualities.bluray576p;
      }
      {
        name = qualities.bluray480p;
      }
      {
        name = "WEB 480p";
        qualities = [
          qualities.webRip480p
          qualities.webDl480p
        ];
      }
      {
        name = qualities.dvd;
      }
      {
        name = qualities.sdtv;
      }
    ];
  };
  webBluray2160p = {
    name = "UHD Bluray + WEB";
    upgrade = {
      allowed = true;
      untilQuality = qualities.bluray2160p;
      untilScore = 10000;
    };
    minFormatScore = 0;
    qualities = [
      {
        name = qualities.bluray2160p;
      }
      {
        name = "WEB 2160p";
        qualities = [
          qualities.webRip2160p
          qualities.webDl2160p
        ];
      }
      {
        name = qualities.bluray1080p;
      }
      {
        name = "WEB 1080p";
        qualities = [
          qualities.webRip1080p
          qualities.webDl1080p
        ];
      }
      {
        name = qualities.bluray720p;
      }
    ];
  };
}
