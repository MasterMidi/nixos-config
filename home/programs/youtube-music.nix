{
  pkgs,
  lib,
  ...
}: {
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/video/netflix/default.nix#L17
  # https://github.com/mathix420/free-the-web-apps/blob/master/apps/youtube-music/youtube-music.desktop
  # https://www.reddit.com/r/unixporn/comments/1aup8kn/oc_unleash_the_power_of_web_apps_forget_about/
  xdg.desktopEntries.youtube-music = {
    type = "Application";
    name = "Youtube Music";
    genericName = "Music player";
    comment = "A new music service with official albums, singles, videos, remixes, live performances and more for Android, iOS and desktop. It's all here.";
    exec = "${pkgs.google-chrome}/bin/${pkgs.google-chrome.meta.mainProgram} --app=https://music.youtube.com/ --no-first-run --no-default-browser-check --no-crash-upload \"\\$@\""; # TODO: switch to ungoogled-chromium
    # icon = ./youtube-music.png;
    icon = pkgs.fetchurl {
      name = "youtube-music-icon.png";
      url = "https://music.youtube.com/img/favicon_144.png"; # TODO: find higher res source or just save in repo
      sha256 = "sha256-xuHQU1LBXb8ATf7uZ+Jz/xnASyzWlMkBfJgn6NjZz1Y=";
      meta.license = lib.licenses.unfree;
    };
    categories = ["AudioVideo" "Player"];
    startupNotify = true;
    settings = {
      StartupWMClass = "youtube-music";
    };
  };
}
