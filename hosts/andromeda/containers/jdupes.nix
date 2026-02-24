# Add this to your NixOS configuration (usually in configuration.nix)
{ self, ... }:
{
  imports = [ self.modules.nixos.jdupes ];
  services.jdupes = {
    enable = true;
    jobs.torrent-deduplication = {
      directories = [ "/mnt/hdd/torrents" ];
      recursive = true;
      action = "dedupe";
      # filters = [ "onlyext:mkv,mp4,avi" ];
      hashDatabase = true;
      interval = "*-*-01 00:00:00"; # 1st of month

      extraServiceConfig = {
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
        CPUSchedulingPolicy = "batch";
        Nice = 10;
      };

      extraTimerConfig = {
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };
    jobs.media-deduplication = {
      directories = [
        "/mnt/hdd/torrents"
        "/mnt/hdd/media"
      ];

      # This forces jdupes to keep the file from the first directory (torrents)
      # and link the file from the second directory (media) to it.
      paramOrder = true;

      # This prevents matching two files that are BOTH in torrents
      # or BOTH in media. Matches only occur BETWEEN them.
      isolate = true;
      recursive = true;
      action = "hardlink";
      hashDatabase = true;
      interval = "*-*-01 00:00:00"; # 1st of month

      extraServiceConfig = {
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
        CPUSchedulingPolicy = "batch";
        Nice = 10;
      };

      extraTimerConfig = {
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };
  };
}
