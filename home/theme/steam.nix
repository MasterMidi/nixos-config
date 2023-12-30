{pkgs, ...}: {
  home.activation = {
    steamTheme = let
      version = "v1.15";
      getFrom = url: hash: {
        package = pkgs.runCommand "moveUp" {} ''
          ./${pkgs.fetchzip {
            url = "${url}/${version}.zip";
            hash = hash;
          }}/install.py -t normal -c gruvbox
        '';
      };
    in
      getFrom
      "https://github.com/tkashkin/Adwaita-for-Steam/archive/refs/tags"
      "";
  };
}
