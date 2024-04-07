let
  qualities = import ../qualities.nix;
in {
  anime = {
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
    min_format_score = 100;
    quality_sort = "top";
    qualities = [
      {
        name = "Bluray 1080p";
        qualities = [
          qualities.bluray1080pRemux
          qualities.bluray1080p
        ];
      }
      {
        name = "WEB 1080p";
        qualities = [
          qualities.webDl1080p
          qualities.webRip1080p
          qualities.hdtv1080p
        ];
      }
      {
        name = qualities.bluray720p;
      }
      {
        name = "WEB 720p";
        qualities = [
          qualities.webDl720p
          qualities.webRip720p
          qualities.hdtv720p
        ];
      }
      {
        name = qualities.bluray480p;
      }
      {
        name = "WEB 480p";
        qualities = [
          qualities.webDl480p
          qualities.webRip480p
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
  webdl = {
    name = "WEB-DL (1080p)";
    upgrade = {
      allowed = true;
      until_quality = "WEB 1080p";
      until_score = 10000;
    };
    min_format_score = 100;
    quality_sort = "top";
    qualities = [
      {
        name = "WEB 1080p";
        qualities = [
          qualities.webDl1080p
          qualities.webRip1080p
        ];
      }
      {
        name = qualities.hdtv1080p;
      }
      {
        name = qualities.bluray720p;
      }
      {
        name = "WEB 720p";
        qualities = [
          qualities.webDl720p
          qualities.webRip720p
        ];
      }
      {
        name = qualities.hdtv720p;
      }
    ];
  };
}
