{ config, ... }:
{
  sops.secrets = {
    PANGOLIN_SERVER_SECRET = {
      sopsFile = ./secrets.sops.yaml;
    };
    STALWART_ADMIN_PASSWORD = {
      sopsFile = ./secrets.sops.yaml;
      # owner = config.users.users.stalwart-mail.name;
      # group = config.users.groups.stalwart-mail.name;
    };
    CLOUDFLARE_GLOBAL_API_KEY = {
      sopsFile = ./secrets.sops.yaml;
    };
    VAULTWARDEN_OIDC_CLIENT_SECRET = {
      sopsFile = ./secrets.sops.yaml;
    };
    # Restic repository encryption password for the Hetzner Storage Box repo.
    RESTIC_REPO_PASSWORD = {
      sopsFile = ./secrets.sops.yaml;
    };
    # Private key for SFTP (port 23) access to the Storage Box sub-account.
    # The matching public key must be added to the sub-account (install-ssh-key).
    STORAGEBOX_RESTIC_SSH_KEY = {
      sopsFile = ./secrets.sops.yaml;
      mode = "0600";
    };
    # Password of the dedicated restic Storage Box sub-account (u560578-sub2).
    # Only needed for manual recovery, e.g. re-adding the SSH key via
    # `cat key.pub | ssh -p 23 u560578-sub2@u560578-sub2.your-storagebox.de install-ssh-key`.
    STORAGEBOX_RESTIC_SUBACCOUNT_PASSWORD = {
      sopsFile = ./secrets.sops.yaml;
      mode = "0400";
    };
    NETBIRD_AUTH_SECRET = {
      sopsFile = ./secrets.sops.yaml;
    };
    NETBIRD_STORE_ENCRYPTION_KEY = {
      sopsFile = ./secrets.sops.yaml;
    };
    NETBIRD_IDP_SESSION_COOKIE_ENCRYPTION_KEY = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
}
