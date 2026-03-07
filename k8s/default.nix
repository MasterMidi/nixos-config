{ ... }:
{
  imports = [
    ./bitmagnet.nix
    ./jellyfin.nix
    # ./linkwarden.nix
    ./newt.nix
    ./nvidia-device-plugin.nix
    ./pocketid.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./qui.nix
    ./radarr.nix
    ./seerr.nix
    ./sonarr.nix
  ];

  kubernetes.resources.none.Namespace.media-stack = { };
  kluctl.deployment.vars = [
    {
      file = ./secrets.yaml;
    }
  ];
}
