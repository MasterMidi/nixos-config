{ pkgs, ... }:

# Storage Box sub-accounts: one per backup method, so they are isolated and
# protected against accidental deletion. The box itself ("backups", id 543132)
# is only looked up as a data source, not managed.
#
# - longhorn: u560578-sub1 (home "longhorn/", CIFS/WebDAV for the Longhorn
#   backup target in k8s/longhorn.nix, SSH disabled).
# - restic: u560578-sub2 (home "restic/", SSH on port 23 for the restic backups
#   in hosts/aether/backup.nix).
#
# A sub-account's authorized_keys cannot be managed through the Hetzner API.
# The restic key was installed once with:
#   cat key.pub | ssh -p 23 u560578-sub2@u560578-sub2.your-storagebox.de install-ssh-key
# Public key (also referenced in hosts/aether/backup.nix):
#   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6ckaamET/BKcu0Erzq8EqODm2aNW/gUclRZ25ZqHSX aether-restic-storagebox
{
  terraform.required_providers.hcloud = {
    source = "hetznercloud/hcloud";
    version = "= ${pkgs.terraform-providers.hetznercloud_hcloud.version}";
  };

  # Passed via TF_VAR_storage_box_restic_subaccount_password (decrypted from
  # infra/secrets/secrets.sops.yaml by the wrapper), so no plaintext lands in
  # the generated config.tf.json. Only used when the sub-account is created;
  # afterwards ignored via lifecycle.ignore_changes (the API never returns it).
  variable.storage_box_restic_subaccount_password = {
    type = "string";
    sensitive = true;
    description = "Password of the restic Storage Box sub-account.";
  };

  # Same value as hetzner_storage_box_543132_sub1_password in k8s/secrets.yaml
  # (used there for the Longhorn backup target credentials).
  variable.storage_box_longhorn_subaccount_password = {
    type = "string";
    sensitive = true;
    description = "Password of the Longhorn Storage Box sub-account.";
  };

  data.hcloud_storage_box.backups = {
    name = "backups";
  };

  resource.hcloud_storage_box_subaccount.longhorn = {
    storage_box_id = "\${data.hcloud_storage_box.backups.id}";
    name = "u560578-sub1";
    home_directory = "longhorn/";
    password = "\${var.storage_box_longhorn_subaccount_password}";
    description = "Longhorn backupstore";
    access_settings = {
      reachable_externally = true;
      samba_enabled = true;
      ssh_enabled = false;
      webdav_enabled = true;
      readonly = false;
    };
    labels = { };

    lifecycle = {
      prevent_destroy = true;
      ignore_changes = [ "password" ];
    };
  };

  resource.hcloud_storage_box_subaccount.restic = {
    storage_box_id = "\${data.hcloud_storage_box.backups.id}";
    name = "restic";
    home_directory = "restic";
    password = "\${var.storage_box_restic_subaccount_password}";
    description = "Restic backups from the aether VPS (see hosts/aether/backup.nix).";
    access_settings = {
      reachable_externally = true;
      samba_enabled = false;
      ssh_enabled = true;
      webdav_enabled = false;
      readonly = false;
    };
    labels = {
      purpose = "restic";
    };

    lifecycle = {
      prevent_destroy = true;
      ignore_changes = [ "password" ];
    };
  };

  # Both sub-accounts already exist; adopt them (created once via the API).
  import = [
    {
      to = "hcloud_storage_box_subaccount.longhorn";
      id = "543132/307774";
    }
    {
      to = "hcloud_storage_box_subaccount.restic";
      id = "543132/377533";
    }
  ];

  output.storage_box_longhorn_subaccount_username.value = "\${hcloud_storage_box_subaccount.longhorn.username}";
  output.storage_box_longhorn_subaccount_server.value = "\${hcloud_storage_box_subaccount.longhorn.server}";
  output.storage_box_restic_subaccount_username.value = "\${hcloud_storage_box_subaccount.restic.username}";
  output.storage_box_restic_subaccount_server.value = "\${hcloud_storage_box_subaccount.restic.server}";
}
