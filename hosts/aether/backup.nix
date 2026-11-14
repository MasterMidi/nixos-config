{
  config,
  pkgs,
  ...
}:
let
  # Off-site backups go to a dedicated Hetzner Storage Box sub-account
  # (u560578-sub2, home directory "restic/", created via the Hetzner API with
  # ssh_enabled + reachable_externally; sub1 belongs to Longhorn and has SSH
  # disabled). The sub-account is chrooted into its own home directory, so
  # repository paths are relative to it. SSH/SFTP runs on port 23 and
  # authenticates with a dedicated key in OpenSSH format, installed on the
  # sub-account via `install-ssh-key`. Public key:
  # ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6ckaamET/BKcu0Erzq8EqODm2aNW/gUclRZ25ZqHSX aether-restic-storagebox
  storageboxAlias = "hetzner-storagebox";
  repository = "sftp:${storageboxAlias}:restic/aether";

  passwordFile = config.sops.secrets.RESTIC_REPO_PASSWORD.path;
  sshKeyFile = config.sops.secrets.STORAGEBOX_RESTIC_SSH_KEY.path;

  sqlite3 = "${pkgs.sqlite}/bin/sqlite3";

  common = {
    inherit repository passwordFile;
    initialize = true;
    extraBackupArgs = [ "--one-file-system" ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
    # Verify a random 2% of the repository data after every backup run.
    checkOpts = [ "--read-data-subset=2%" ];
    timerConfig = {
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
in
{
  # restic's sftp backend shells out to ssh(1); the backup services run as
  # root, so the system-wide client config below is what gets picked up.
  programs.ssh.hosts.${storageboxAlias} = {
    order = 100;
    hostname = "u560578-sub2.your-storagebox.de";
    user = "u560578-sub2";
    port = 23;
    identityFile = sshKeyFile;
    identitiesOnly = true;
    # The Storage Box drops idle SFTP connections; keep them alive through
    # long scans of mostly-unchanged data.
    serverAliveInterval = 60;
    serverAliveCountMax = 240;
  };

  # Pinned host key (ssh-keyscan -p 23), matches Hetzner's published Storage
  # Box ED25519 fingerprint SHA256:XqONwb1S0zuj5A1CDxpOSuD2hnAArV1A3wKY7Z3sdgM.
  programs.ssh.knownHosts.storagebox = {
    hostNames = [
      "u560578-sub2.your-storagebox.de"
      "[u560578-sub2.your-storagebox.de]:23"
    ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
  };

  services.restic.backups = {
    vaultwarden = common // {
      paths = [
        "/mnt/ssd/services/vaultwarden/data"
        "/run/restic-staging/vaultwarden"
      ];
      # The live SQLite db (WAL) is excluded in favour of a consistent staged copy.
      exclude = [ "/mnt/ssd/services/vaultwarden/data/db.sqlite3*" ];
      backupPrepareCommand = ''
        mkdir -p /run/restic-staging/vaultwarden
        ${sqlite3} /mnt/ssd/services/vaultwarden/data/db.sqlite3 ".backup '/run/restic-staging/vaultwarden/db.sqlite3'"
      '';
      backupCleanupCommand = "rm -rf /run/restic-staging/vaultwarden";
      extraBackupArgs = common.extraBackupArgs ++ [
        "--tag"
        "vaultwarden"
      ];
      timerConfig = common.timerConfig // {
        OnCalendar = "*-*-* 02:30:00";
      };
    };

    pangolin = common // {
      # config.yml, the SQLite db, the gerbil wireguard key and the ACME certs.
      paths = [
        "/containers/pangolin/config"
        "/run/restic-staging/pangolin"
      ];
      exclude = [
        "/containers/pangolin/config/db/db.sqlite*"
        "/containers/pangolin/config/logs"
        "/containers/pangolin/config/traefik/logs"
      ];
      backupPrepareCommand = ''
        mkdir -p /run/restic-staging/pangolin
        ${sqlite3} /containers/pangolin/config/db/db.sqlite ".backup '/run/restic-staging/pangolin/db.sqlite'"
      '';
      backupCleanupCommand = "rm -rf /run/restic-staging/pangolin";
      extraBackupArgs = common.extraBackupArgs ++ [
        "--tag"
        "pangolin"
      ];
      timerConfig = common.timerConfig // {
        OnCalendar = "*-*-* 03:30:00";
      };
    };

    stalwart = common // {
      # RocksDB under db/ is crash-safe (WAL), so a file-level snapshot of the
      # running service recovers to a consistent state, like after a crash.
      paths = [ "/var/lib/stalwart-16" ];
      # Rebuilt from the nix store on every start.
      exclude = [
        "/var/lib/stalwart-16/webui"
        "/var/lib/stalwart-16/cache"
      ];
      extraBackupArgs = common.extraBackupArgs ++ [
        "--tag"
        "stalwart"
      ];
      timerConfig = common.timerConfig // {
        OnCalendar = "*-*-* 04:30:00";
      };
    };

    netbird = common // {
      paths = [
        "/var/lib/netbird"
        "/run/restic-staging/netbird"
      ];
      exclude = [
        "/var/lib/netbird/store.db*"
        "/var/lib/netbird/events.db*"
        "/var/lib/netbird/idp.db*"
      ];
      backupPrepareCommand = ''
        mkdir -p /run/restic-staging/netbird
        for db in store.db events.db idp.db; do
          ${sqlite3} "/var/lib/netbird/$db" ".backup '/run/restic-staging/netbird/$db'"
        done
      '';
      backupCleanupCommand = "rm -rf /run/restic-staging/netbird";
      extraBackupArgs = common.extraBackupArgs ++ [
        "--tag"
        "netbird"
      ];
      timerConfig = common.timerConfig // {
        OnCalendar = "*-*-* 05:30:00";
      };
    };
  };
}
