{...}: let
  browser = "firefox.desktop";
  imageViewer = "pix.desktop";
  audioPlayer = "org.gnome.rhythmbox3.desktop";
in {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/gif" = [imageViewer];
      "application/x-extension-shtml" = browser;
      "application/xhtml+xml" = browser;
      "application/x-extension-xhtml" = browser;
      "application/x-extension-xht" = browser;
      "image/jpeg" = imageViewer;
      "audio/x-vorbis+ogg" = audioPlayer;
      "audio/vorbis" = audioPlayer;
      "audio/x-vorbis" = audioPlayer;
      "audio/x-scpls" = audioPlayer;
      "audio/x-mp3" = audioPlayer;
      "audio/x-mpeg" = audioPlayer;
      "audio/x-mpegurl" = audioPlayer;
      "audio/x-flac" = audioPlayer;
      "audio/mp4" = audioPlayer;
      "audio/x-it" = audioPlayer;
      "audio/x-mod" = audioPlayer;
      "audio/x-s3m" = audioPlayer;
      "audio/x-stm" = audioPlayer;
      "audio/x-xm" = audioPlayer;
      "image/png" = imageViewer;
      "image/webp" = imageViewer;
      "image/tiff" = imageViewer;
      "image/x-tga" = imageViewer;
      "image/vnd-ms.dds" = imageViewer;
      "image/x-dds" = imageViewer;
      "image/bmp" = imageViewer;
      "image/vnd.microsoft.icon" = imageViewer;
      "image/vnd.radiance" = imageViewer;
      "image/x-exr" = imageViewer;
      "image/x-portable-bitmap" = imageViewer;
      "image/x-portable-graymap" = imageViewer;
      "image/x-portable-pixmap" = imageViewer;
      "image/x-portable-anymap" = imageViewer;
      "image/x-qoi" = imageViewer;
      "image/svg+xml" = imageViewer;
      "image/svg+xml-compressed" = imageViewer;
      "image/avif" = imageViewer;
      "image/heic" = imageViewer;
      "image/jxl" = imageViewer;
      "x-scheme-handler/ror2mm" = "r2modman.desktop";
    };
    associations.added = {
      "x-scheme-handler/mailto" = "userapp-Thunderbird-L02IE2.desktop";
      "x-scheme-handler/mid" = "userapp-Thunderbird-L02IE2.desktop";
      "x-scheme-handler/webcal" = "userapp-Thunderbird-TJPIE2.desktop";
      "x-scheme-handler/webcals" = "userapp-Thunderbird-TJPIE2.desktop";
      "video/x-matroska" = "vlc.desktop";
      "audio/flac" = audioPlayer;
      "x-scheme-handler/chrome" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "text/html" = browser;
      "video/mp4" = "vlc.desktop";
    };
  };
}
