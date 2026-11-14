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

      terranix.terranixConfigurations.hcloud-storage-box = {
        modules = [ ./hcloud-storage-box.nix ];
        workdir = "infra/.terranix/hcloud-storage-box";
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
            if [[ -z "''${TF_VAR_storage_box_restic_subaccount_password:-}" ]]; then
              TF_VAR_storage_box_restic_subaccount_password="$(
                sops --decrypt \
                  --extract '["hetzner_storage_box_restic_subaccount_password"]' \
                  ${./secrets/secrets.sops.yaml}
              )"
              export TF_VAR_storage_box_restic_subaccount_password
            fi
            if [[ -z "''${TF_VAR_storage_box_longhorn_subaccount_password:-}" ]]; then
              TF_VAR_storage_box_longhorn_subaccount_password="$(
                sops --decrypt \
                  --extract '["hetzner_storage_box_longhorn_subaccount_password"]' \
                  ${./secrets/secrets.sops.yaml}
              )"
              export TF_VAR_storage_box_longhorn_subaccount_password
            fi
          '';
        };
      };
    };
}
