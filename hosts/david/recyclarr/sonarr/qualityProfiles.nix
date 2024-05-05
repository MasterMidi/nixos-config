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
    min_format_score = 10;
    quality_sort = "top";
    qualities = [
      {
        name = "Bluray 1080p";
        qualities = [
          qualities.bluray1080pRemux
          qualities.bluray1080p
        ];
      }
      {name = qualities.webDl1080p;}
      {name = qualities.webRip1080p;}
      {name = qualities.hdtv1080p;}
      {name = qualities.bluray720p;}
      {name = qualities.webDl720p;}
      {name = qualities.webRip720p;}
      {name = qualities.hdtv720p;}
      {name = qualities.bluray480p;}
      {name = qualities.webDl480p;}
      {name = qualities.webRip480p;}
      {name = qualities.dvd;}
      {name = qualities.sdtv;}
    ];
  };
  webdl = {
    name = "WEB-DL (1080p)";
    upgrade = {
      allowed = true;
      until_quality = qualities.webDl1080p;
      until_score = 10000;
    };
    min_format_score = 10;
    quality_sort = "top";
    qualities = [
      {
        name = qualities.webDl1080p;
      }
      {
        name = qualities.webRip1080p;
      }
      {
        name = qualities.hdtv1080p;
      }
      {
        name = qualities.bluray720p;
      }
      {
        name = qualities.webDl720p;
      }
      {
        name = qualities.webRip720p;
      }
      {
        name = qualities.hdtv720p;
      }
    ];
  };
}
