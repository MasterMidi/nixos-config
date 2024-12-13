let
  qualities = import ../qualities.nix;
in {
  anime = {
    name = "Anime";
    scoreSet = "anime-sonarr";
    resetUnmatchedScores.enabled = true;
    upgrade = {
      allowed = true;
      untilQuality = "Bluray 1080p";
      untilScore = 10000;
    };
    minFormatScore = 0;
    qualitySort = "top";
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
      {name = qualities.bluray720p;}
      {
        name = "WEB 720p";
        qualities = [
          qualities.webDl720p
          qualities.webRip720p
          qualities.hdtv720p
        ];
      }
      {name = qualities.bluray480p;}
      {name = qualities.dvd;}
      {name = qualities.sdtv;}
    ];
  };
  webdl = {
    name = "WEB-DL (1080p)";
    upgrade = {
      allowed = true;
      untilQuality = qualities.bluray1080p;
      untilScore = 10000;
    };
    minFormatScore = 0;
    qualitySort = "top";
    qualities = [
      {
        name = qualities.bluray1080p;
        qualities = [
          qualities.bluray1080pRemux
          qualities.bluray1080p
        ];
      }
      {
        name = qualities.webDl1080p;
        qualities = [
          qualities.webDl1080p
          qualities.webRip1080p
        ];
      }
      {name = qualities.hdtv1080p;}
      {name = qualities.bluray720p;}
      {
        name = qualities.webDl720p;
        qualities = [
          qualities.webDl720p
          qualities.webRip720p
        ];
      }
      {name = qualities.hdtv720p;}
    ];
  };
}
