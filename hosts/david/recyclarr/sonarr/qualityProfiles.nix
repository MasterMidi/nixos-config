let
  qualities = import ../qualities.nix;
in {
  anime = {
    name = "Anime";
    resetUnmatchedScores = {
      enabled = true;
      except = [];
    };
    upgrade = {
      allowed = true;
      untilQuality = "Bluray 1080p";
      untilScore = 10000;
    };
    minFormatScore = 10;
    qualitySort = "top";
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
      untilQuality = qualities.webDl1080p;
      untilScore = 10000;
    };
    minFormatScore = 10;
    qualitySort = "top";
    qualities = [
      {name = qualities.webDl1080p;}
      {name = qualities.webRip1080p;}
      {name = qualities.hdtv1080p;}
      {name = qualities.bluray720p;}
      {name = qualities.webDl720p;}
      {name = qualities.webRip720p;}
      {name = qualities.hdtv720p;}
    ];
  };
}
