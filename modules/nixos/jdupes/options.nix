{
  lib,
  pkgs,
  ...
}:
{
  options.services.jdupes = {
    enable = lib.mkEnableOption "jdupes automated cleanup service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.jdupes;
      defaultText = lib.literalExpression "pkgs.jdupes";
      description = "The jdupes package to use.";
    };

    jobs = lib.mkOption {
      description = "List of jdupes cleanup jobs to run periodically.";
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, config, ... }:
          {
            options = {
              # --- Target Configuration ---
              directories = lib.mkOption {
                type = lib.types.nonEmptyListOf lib.types.path;
                description = "List of directories to scan for duplicates.";
                example = [
                  "/var/lib/media"
                  "/home/user/Downloads"
                ];
              };

              recursive = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Whether to recurse into subdirectories (maps to `-r`).";
              };

              oneFileSystem = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Do not match files on different filesystems/devices (maps to `-1`).";
              };

              isolate = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Files in the same specified directory won't match (maps to `-I`).";
              };

              paramOrder = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Sort output based on the order of directory arguments (maps to `-O`).";
              };

              # --- Action Configuration ---
              action = lib.mkOption {
                type = lib.types.enum [
                  "print"
                  "hardlink"
                  "symlink"
                  "dedupe"
                  "delete"
                ];
                default = "print";
                description = ''
                  The action to perform on duplicate files:
                  - print: Just list duplicates (default behavior).
                  - hardlink: Link duplicates using hard links (maps to `-L`).
                  - symlink: Link duplicates using relative symlinks (maps to `-l`).
                  - dedupe: Perform copy-on-write deduplication using reflink (BTRFS/XFS only) (maps to `-B`).
                  - delete: Delete duplicate files. WARNING: This implies `-N` (no prompt).
                '';
              };

              order = lib.mkOption {
                type = lib.types.enum [
                  "name"
                  "time"
                ];
                default = "time";
                description = ''
                  Sort order for output and deciding which file to keep.
                  'time' modifies by modification time; 'name' sorts by filename (maps to `-o`).
                '';
              };

              reverse = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Reverse the sort order (maps to `-i`).";
              };

              # --- Filtering ---
              noHidden = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Exclude hidden files from consideration (maps to `-A`).";
              };

              filters = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                example = [
                  "onlyext:mkv,mp4"
                  "size+:100M"
                ];
                description = "List of extension/size/string filters passed to `-X`.";
              };

              # --- Advanced / Performance ---
              hashDatabase = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                  Enable the hash database feature (`-y`) to speed up subsequent runs.
                  This automatically creates a state directory in `/var/lib/jdupes/<job-name>`.

                '';
              };

              permissions = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "If true, requires owner/group/permissions to match to be considered duplicates (maps to `-p`).";
              };

              hardLinks = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Treat existing hard linked files as duplicates. Normally they are ignored (maps to `-H`).";
              };

              # --- Systemd Integration ---
              interval = lib.mkOption {
                type = lib.types.str;
                default = "monthly";
                description = "Systemd OnCalendar interval for when to run this job (e.g., 'daily', 'weekly', 'Mon 04:00').";
              };

              user = lib.mkOption {
                type = lib.types.str;
                default = "root";
                description = "User to run the service as.";
              };

              extraServiceConfig = lib.mkOption {
                type = lib.types.attrs;
                default = { };
                description = "Extra configuration for the Systemd Service section (e.g. Nice, CPUSchedulingPolicy).";
              };

              extraTimerConfig = lib.mkOption {
                type = lib.types.attrs;
                default = { };
                description = "Extra configuration for the Systemd Timer section (e.g. RandomizedDelaySec).";
              };
            };
          }
        )
      );
    };
  };
}
