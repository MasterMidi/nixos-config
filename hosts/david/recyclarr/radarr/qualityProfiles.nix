let
  qualities = import ../qualities.nix;
in {
  animeRemux1080p = {
    name = "Anime Remux (1080p)";
    upgrade = {
      allowed = true;
      until_quality = qualities.remux1080p;
      until_score = 10000;
    };
    min_format_score = 100;
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
        name = "SDTV";
      }
    ];
  };
  animeRemux2160p = {
    name = "Anime Remux (2160p)";
    upgrade = {
      allowed = true;
      until_quality = qualities.remux2160p;
      until_score = 10000;
    };
    min_format_score = 100;
    qualities = [
      {
        name = qualities.remux2160p;
      }
      {
        name = qualities.bluray2160p;
      }
      {
        name = "WEB 2160p";
        qualities = [
          qualities.webRip2160p
          qualities.webDl2160p
          qualities.hdtv2160p
        ];
      }
      {
        name = "Remux 1080p";
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
  webRemux2160p = {
    name = "Remux + WEB (2160p)";
    upgrade = {
      allowed = true;
      until_quality = qualities.remux2160p;
      until_score = 10000;
    };
    min_format_score = 100;
    qualities = [
      {
        name = qualities.remux2160p;
      }
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
    ];
  };
  webRemux1080p = {
    name = "Remux + WEB (1080p)";
    upgrade = {
      allowed = true;
      until_quality = qualities.remux1080p;
      until_score = 10000;
    };
    min_format_score = 100;
    qualities = [
      {
        name = qualities.remux1080p;
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
    ];
  };
  legacy = {
    name = "Legacy";
    upgrade = {
      allowed = true;
      until_quality = qualities.bluray720p;
      until_score = 10000;
    };
    min_format_score = 0;
    qualities = [
      {
        name = qualities.bluray720p;
      }
      {
        name = "WEB 720p";
        qualities = [
          qualities.webRip720p
          qualities.webDl720p
        ];
      }
      {
        name = qualities.hdtv720p;
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
        name = qualities.sdtv;
      }
      {
        name = qualities.dvdR;
      }
      {
        name = qualities.dvd;
      }
    ];
  };
}
