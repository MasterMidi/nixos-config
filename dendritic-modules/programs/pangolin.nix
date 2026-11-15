{ ... }:
{
  flake.nixosModules.pangolin-client =
    { pkgs, ... }:
    let
      # Pangolin client (https://github.com/fosrl/cli) for reaching private
      # resources behind tunnel.mgrlab.dk. nixpkgs pins 0.18.1, which predates
      # client identity support for private resource HTTP requests (added in
      # 0.19.0), so override to the latest release until nixpkgs catches up.
      pangolin-cli = pkgs.pangolin-cli.overrideAttrs (old: rec {
        version = "0.21.0";
        src = pkgs.fetchFromGitHub {
          owner = "fosrl";
          repo = "cli";
          tag = version;
          hash = "sha256-GbN8kKlixvo1BObE9fRYZ92jTnNdtOnHTpnOaeKB770=";
        };
        vendorHash = "sha256-6xLlZs62vKhtZU/t8rkc2rA2f3QqJXaF5yaytcbX6k0=";
      });
    in
    {
      # Fail the build once nixpkgs ships pangolin-cli the same or newer version, so the
      # version override above can be removed.
      assertions = [
        {
          assertion = (builtins.compareVersions pkgs.pangolin-cli.version pangolin-cli.version) < 0;
          message = ''
            nixpkgs pangolin-cli is now version ${pkgs.pangolin-cli.version} (>= ${toString pangolin-cli.version}).
            The version override in dendritic-modules/programs/pangolin.nix is
            no longer needed: remove the overrideAttrs block and install
            pkgs.pangolin-cli directly.
          '';
        }
      ];

      # Installed system-wide so `sudo pangolin up` can create the tunnel
      # interface; login state lives in the invoking user's home directory.
      environment.systemPackages = [ pangolin-cli ];

      # The Pangolin client also uses CGNAT-range subnets (100.64.0.0/10) for
      # its tunnel. Tailscale's netfilter rules include an anti-spoof DROP in
      # ts-input for all CGNAT-source packets on !tailscale0, which silently
      # kills the Pangolin client's tunnel traffic (its TUN delivers replies
      # via INPUT with CGNAT sources) whenever Tailscale is up. Disable
      # Tailscale's netfilter management: the NixOS firewall already covers
      # what those rules did (tailscale0 is a trusted interface, UDP 41641 is
      # open, and default-deny preserves the anti-spoof protection). Without
      # this, enabling Tailscale breaks the Pangolin client's DNS proxy and
      # all private-resource access. Harmless on hosts without Tailscale.
      services.tailscale.extraSetFlags = [ "--netfilter-mode=off" ];
    };
}
