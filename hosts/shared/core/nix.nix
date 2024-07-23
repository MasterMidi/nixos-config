{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
  };

  environment.systemPackages = with pkgs; [nh];

  environment.variables = {
    FLAKE = "/etc/nixos/";
  };

  environment.etc = {
    # "nix/flake-channels/nixpkgs".source = inputs.nixpkgs;
    # "nix/flake-channels/home-manager".source = inputs.home-manager;
  };

  nix = {
    # set the path for channels compat
    # nixPath = [
    #   "nixpkgs=/etc/nix/flake-channels/nixpkgs"
    #   "home-manager=/etc/nix/flake-channels/home-manager"
    # ];
    channel.enable = false;

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    optimise = {
      automatic = true;
      dates = ["daily"];
    };

    package = pkgs.nixVersions.latest; # use the newest vwersion of the nix package manager

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time using 'nix shell nixpkgs#...'
    # registry = lib.mapAttrs (_: v: {flake = v;}) inputs;
    daemonCPUSchedPolicy = lib.mkDefault "idle";
    daemonIOSchedClass = lib.mkDefault "idle";
    daemonIOSchedPriority = lib.mkDefault 7;

    settings = {
      experimental-features =
        ["nix-command" "flakes" "auto-allocate-uids" "cgroups" "fetch-closure" "recursive-nix"]
        ++ lib.optional (lib.versionAtLeast (lib.versions.majorMinor config.nix.package.version) "2.19")
        # Allow the use of the impure-env setting.
        "configurable-impure-env"
        ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.18")
        # allows to drop references from filesystem images
        "discard-references";
      keep-outputs = true;
      warn-dirty = false;
      keep-derivations = true;
      # use-xdg-base-directories = true

      system-features = ["recursive-nix" "uid-range"];

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

      trusted-users = ["@wheel"];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
        "https://numtide.cachix.org"
        "https://raspberry-pi-nix.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
      ];
    };
  };
  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 250;

  system.autoUpgrade.enable = false;
}
