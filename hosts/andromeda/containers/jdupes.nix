# Add this to your NixOS configuration (usually in configuration.nix)
{
  config,
  lib,
  pkgs,
  ...
}: let
  program-files = "/var/lib/jdupes";
  extensions = [
    "mkv"
    "mp4"
    "avi"
  ];
in {
  # Ensure jdupes is installed
  environment.systemPackages = with pkgs; [
    jdupes
  ];

  # Create tmpfiles definition to ensure directories exist
  systemd.tmpfiles.rules = [
    "d ${program-files} 0755 root root - -" # Create main directory
  ];

  # Create the systemd service and timer
  systemd.services.media-deduplication = {
    description = "Monthly media file deduplication";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.jdupes}/bin/jdupes --recurse --link-hard \
        --ext-filter=onlyext:${builtins.concatStringsSep "," extensions} \
        --hash-db=${program-files}/hashdb.txt \
        /mnt/hdd
      '';
      User = "root"; # Change this if you want another user to run the service

      # More balanced resource settings
      IOSchedulingClass = "best-effort"; # Default class but with lower priority
      IOSchedulingPriority = 7; # Range is 0-7, with 7 being lowest priority
      CPUSchedulingPolicy = "batch"; # Better for background CPU-intensive jobs
      Nice = 10; # Medium-low priority (not as extreme as 19)
    };
  };

  # Configure the timer to run on the first day of each month
  # with a random start time within 30 minutes after midnight
  systemd.timers.media-deduplication = {
    description = "Run media deduplication on the 1st day of each month";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-01 00:00:00"; # First day of each month at midnight
      RandomizedDelaySec = "30m"; # Add a random delay of up to 30 minutes
      Persistent = true; # Run immediately if system was off during scheduled time
      Unit = config.systemd.services.media-deduplication.name;
    };
  };
}
