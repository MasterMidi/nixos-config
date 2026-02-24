{
  config,
  lib,
  ...
}:

let
  cfg = config.services.jdupes;

  # Helper to escape shell arguments safely
  escape = lib.strings.escapeShellArg;

  # Version check constants
  testedMajor = 1;
  testedMinor = 31;
in
{
  config = lib.mkIf cfg.enable {
    warnings =
      let
        v = lib.versions;
        pkgVer = cfg.package.version;
        currMajor = lib.toInt (v.major pkgVer);
        currMinor = lib.toInt (v.minor pkgVer);
        isTooNew = (currMajor > testedMajor) || (currMajor == testedMajor && currMinor > testedMinor);
      in
      lib.optional isTooNew ''
        The configured jdupes version (${pkgVer}) is newer than the tested version (${toString testedMajor}.${toString testedMinor}.x).
        Verify compatibility at https://codeberg.org/jbruchon/jdupes
      '';

    systemd.services = lib.mapAttrs' (
      name: job:
      let
        actionFlag =
          if job.action == "hardlink" then
            "--link-hard"
          else if job.action == "symlink" then
            "--link-soft"
          else if job.action == "dedupe" then
            "--dedupe"
          else if job.action == "delete" then
            "--delete --no-prompt"
          else
            ""; # print is default

        # State directory path (auto-managed by systemd)
        stateDir = "/var/lib/jdupes/${name}";
        hashDbFlag = if job.hashDatabase then "--hash-db=${stateDir}/hashdb.txt" else "";

        filterFlags = builtins.concatStringsSep " " (map (f: "--ext-filter=${escape f}") job.filters);

      in
      lib.nameValuePair "jdupes-${name}" {
        description = "jdupes cleanup job: ${name}";

        serviceConfig = {
          Type = "oneshot";
          User = job.user;

          # Binary execution
          ExecStart = builtins.concatStringsSep " " [
            "${cfg.package}/bin/jdupes"
            (lib.optionalString job.recursive "--recurse")
            (lib.optionalString job.oneFileSystem "--one-file-system")
            (lib.optionalString job.noHidden "--no-hidden")
            (lib.optionalString job.permissions "--permissions")
            (lib.optionalString job.hardLinks "--hard-links")
            (lib.optionalString job.reverse "--reverse")
            (lib.optionalString job.isolate "--isolate")
            (lib.optionalString job.paramOrder "--param-order")
            "--order=${job.order}"
            actionFlag
            hashDbFlag
            filterFlags
            (builtins.concatStringsSep " " (map escape job.directories))
          ];

          StateDirectory = lib.mkIf job.hashDatabase "jdupes/${name}";
        }
        // job.extraServiceConfig;
      }
    ) cfg.jobs;

    systemd.timers = lib.mapAttrs' (
      name: job:
      lib.nameValuePair "jdupes-${name}" {
        description = "Timer for jdupes cleanup job: ${name}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = job.interval;
          Unit = "jdupes-${name}.service";
        }
        // job.extraTimerConfig;
      }
    ) cfg.jobs;
  };
}
