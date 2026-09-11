{ ... }:
{
  imports = [
    ./alloy.nix
    ./autobrr.nix
    ./bazarr.nix
    ./bitmagnet.nix
    ./dawarich.nix
    ./immich.nix
    ./jellyfin.nix
    # # ./linkwarden.nix
    ./lldap.nix
    ./longhorn.nix
    ./newt.nix
    ./nvidia-device-plugin.nix
    # ./obsidian-livesync.nix
    ./paperless.nix
    ./pingvin-share-x.nix
    ./pocketid.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./qui.nix
    ./radarr.nix
    ./recyclarr.nix
    ./scrutiny.nix
    ./seerr.nix
    ./sonarr.nix
    ./subgen.nix
    ./trek.nix
  ];

  kubernetes.resources.none.Namespace.media-stack = { };
  kluctl.deployment.vars = [
    {
      file = ./secrets.yaml;
    }
  ];
}
