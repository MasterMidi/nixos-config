{...}: let
  browser = "firefox.desktop";
  imageViewer = "pix.desktop";
  audioPlayer = "org.gnome.rhythmbox3.desktop";
  videoPlayer = "mpv.desktop";

  generateMappings = {
    type,
    extensions,
    viewer,
  }: let
    makePair = ext: {"${type}/${ext}" = viewer;};
    mergeAttrs = list: builtins.foldl' (acc: elem: acc // elem) {} list;
  in
    mergeAttrs (map makePair extensions);
in {
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      generateMappings {
        type = "application";
        extensions = [
          "x-extension-shtml"
          "x-extension-xht"
          "x-extension-xhtml"
          "xhtml+xml"
        ];
        viewer = browser;
      }
      // generateMappings {
        type = "audio";
        extensions = [
          "vorbis"
          "x-flac"
          "x-it"
          "x-mod"
          "x-mp3"
          "x-mpeg"
          "x-mpegurl"
          "x-s3m"
          "x-scpls"
          "x-stm"
          "x-vorbis"
          "x-vorbis+ogg"
          "x-xm"
        ];
        viewer = audioPlayer;
      }
      // generateMappings {
        type = "image";
        extensions = [
          "avif"
          "bmp"
          "gif"
          "heic"
          "jpeg"
          "jxl"
          "png"
          "svg+xml-compressed"
          "svg+xml"
          "tiff"
          "vnd-ms.dds"
          "vnd.microsoft.icon"
          "vnd.radiance"
          "webp"
          "x-dds"
          "x-exr"
          "x-portable-anymap"
          "x-portable-bitmap"
          "x-portable-graymap"
          "x-portable-pixmap"
          "x-qoi"
          "x-tga"
        ];
        viewer = imageViewer;
      }
      // generateMappings {
        type = "video";
        extensions = [
          "x-matroska"
          "mp4"
        ];
        viewer = videoPlayer;
      }
      // generateMappings {
        type = "x-scheme-handler";
        extensions = ["ror2mm"];
        viewer = "r2modman.desktop";
      };
    associations.added = {
      "x-scheme-handler/mailto" = "userapp-Thunderbird-L02IE2.desktop";
      "x-scheme-handler/mid" = "userapp-Thunderbird-L02IE2.desktop";
      "x-scheme-handler/webcal" = "userapp-Thunderbird-TJPIE2.desktop";
      "x-scheme-handler/webcals" = "userapp-Thunderbird-TJPIE2.desktop";
      "audio/flac" = audioPlayer;
      "x-scheme-handler/chrome" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "text/html" = browser;
    };
  };
}
