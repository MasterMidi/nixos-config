{...}: let
  browser = "firefox.desktop";
  imageViewer = "pix.desktop";
  audioPlayer = "org.gnome.rhythmbox3.desktop";
  videoPlayer = "mpv.desktop";

  generateMappings = {
    type,
    extensions,
    app,
  }: let
    makePair = ext: {"${type}/${ext}" = app;};
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
          "x-extension-html"
          "x-extension-htm"
          "xhtml+xml"
        ];
        app = browser;
      }
      // generateMappings {
        type = "x-scheme-handler";
        extensions = [
          "http"
          "https"
        ];
        app = browser;
      }
      // generateMappings {
        type = "application";
        extensions = [
          "pdf"
        ];
        app = "zathura.desktop";
      }
      // generateMappings {
        type = "audio";
        extensions = [
          "vorbis"
          "x-flac"
          "flac"
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
        app = audioPlayer;
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
        app = imageViewer;
      }
      // generateMappings {
        type = "video";
        extensions = [
          "x-matroska"
          "mp4"
        ];
        app = videoPlayer;
      }
      // generateMappings {
        type = "x-scheme-handler";
        extensions = ["ror2mm"];
        app = "r2modman.desktop";
      };
    associations.added = {
      "x-scheme-handler/mailto" = "userapp-Thunderbird-L02IE2.desktop";
      "x-scheme-handler/mid" = "userapp-Thunderbird-L02IE2.desktop";
      "x-scheme-handler/webcal" = "userapp-Thunderbird-TJPIE2.desktop";
      "x-scheme-handler/webcals" = "userapp-Thunderbird-TJPIE2.desktop";
      "x-scheme-handler/chrome" = browser;
      "text/html" = browser;
    };
  };
}
