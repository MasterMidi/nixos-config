{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
  };

  nix = {
    package = pkgs.nixVersions.latest;

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time using 'nix shell nixpkgs#...'
    registry = lib.mapAttrs (_: f: {flake = f;}) inputs;

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];

    settings = {
      experimental-features =
        ["nix-command" "flakes" "auto-allocate-uids" "cgroups" "fetch-closure" "recursive-nix" "pipe-operators"]
        ++ lib.optional (lib.versionAtLeast (lib.versions.majorMinor config.nix.package.version) "2.19")
        # Allow the use of the impure-env setting.
        "configurable-impure-env"
        ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.18")
        # allows to drop references from filesystem images
        "discard-references";

      keep-outputs = true;
      warn-dirty = false;
      keep-derivations = true;

      system-features = ["big-parallel" "recursive-nix" "uid-range" "nixos-test" "benchmark" "kvm"];

      # Free up to 1GiB whenever there is less than 100MiB left.
      min-free = 512 * 1024 * 1024;
      max-free = 3000 * 1024 * 1024;

      # Fallback quickly if substituters are not available.
      connect-timeout = 5;

      # The default at 10 is rarely enough.
      log-lines = 25;

      auto-optimise-store = true;
      auto-allocate-uids = true;
      builders-use-substitutes = true;
      max-jobs = "auto";

      trusted-users = ["@wheel"]; # allow wheel group to run nix commands
    };
  };

  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 250;
}
