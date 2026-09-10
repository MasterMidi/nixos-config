{ inputs, ... }:
{
  imports = [ inputs.terranix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      terranix.terranixConfigurations.cloudflare-dns = {
        modules = [ ./cloudflare-dns.nix ];
        workdir = "infra/.terranix/cloudflare-dns";
        terraformWrapper = {
          package = pkgs.opentofu.withPlugins (plugins: [
            plugins.cloudflare_cloudflare
          ]);

          extraRuntimeInputs = [ pkgs.sops ];

          prefixText = ''
            if [[ -z "''${CLOUDFLARE_API_TOKEN:-}" ]]; then
              CLOUDFLARE_API_TOKEN="$(
                sops --decrypt \
                  --extract '["cloudflare_api_token"]' \
                  ${./secrets/secrets.sops.yaml}
              )"
              export CLOUDFLARE_API_TOKEN
            fi
          '';
        };
      };

      terranix.terranixConfigurations.hcloud-aether = {
        modules = [ ./hcloud-aether.nix ];
        workdir = "infra/.terranix/hcloud-aether";
        terraformWrapper = {
          package = pkgs.opentofu.withPlugins (plugins: [
            plugins.hetznercloud_hcloud
          ]);

          extraRuntimeInputs = [ pkgs.sops ];

          prefixText = ''
            if [[ -z "''${HCLOUD_TOKEN:-}" ]]; then
              HCLOUD_TOKEN="$(
                sops --decrypt \
                  --extract '["hcloud_api_token"]' \
                  ${./secrets/secrets.sops.yaml}
              )"
              export HCLOUD_TOKEN
            fi
          '';
        };
      };
    };
}
