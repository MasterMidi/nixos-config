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
    };
}
