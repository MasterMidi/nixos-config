{ pkgs, config, ... }:
let
  hetznerRecurringJobSelector = [
    {
      name = "hetzner-backup";
      isGroup = true;
    }
  ];
in
{
  kubernetes.resources.longhorn-system = {
    StorageClass.longhorn-database = {
      metadata.annotations.storageclass."kubernetes.io/is-default-class" = false;
      provisioner = "driver.longhorn.io";
      allowVolumeExpansion = true;
      reclaimPolicy = "Retain";
      volumeBindingMode = "Immediate";
      parameters = {
        numberOfReplicas = "1";
        backupTargetName = "hetzner";
        dataLocality = "best-effort";
        fsType = "xfs";
        staleReplicaTimeout = "2880";
        diskSelector = "ssd,fast";
        # mkfsParams = "-I 256 -b 4096 -O ^metadata_csum,^64bit";
        # unmapMarkSnapChainRemoved = "enabled";
        # nodeSelector = "storage,fast";
        recurringJobSelector = builtins.toJSON hetznerRecurringJobSelector;
        # nfsOptions = "soft,timeo=150,retrans=3";
      };
      mountOptions = [
        "noatime" # Don't update file access times
        "nodiratime" # Don't update directory access times
      ];
    };

    Secret.hetzner-storagebox-cifs = {
      stringData = {
        CIFS_USERNAME = "u560578";
        CIFS_PASSWORD = "{{ secrets.hetzner_storage_box_543132_password }}";
      };
    };

    BackupTarget.hetzner = {
      spec = {
        backupTargetURL = "cifs://u560578.your-storagebox.de/backup";
        credentialSecret =
          config.kubernetes.resources.longhorn-system.Secret.hetzner-storagebox-cifs.metadata.name;
        pollInterval = "5m0s";
      };
    };

    RecurringJob.daily-backup = {
      spec = {
        cron = "0 23 * * *";
        task = "backup";
        groups = [ "hetzner-backup" ];
        retain = 7;
        concurrency = 1;
        parameters.full-backup-interval = "7";
      };
    };

    RecurringJob.nightly-filesystem-trim = {
      spec = {
        cron = "0 7 * * *";
        task = "filesystem-trim";
        groups = [ "hetzner-backup" ];
        concurrency = 1;
      };
    };

    RecurringJob.prune-local-snapshots = {
      spec = {
        cron = "0 8 * * *";
        task = "snapshot-cleanup";
        groups = [ "hetzner-backup" ];
        concurrency = 1;
      };
    };
  };

  helm.releases.longhorn = {
    namespace = "longhorn-system";
    chart = pkgs.fetchHelm {
      repo = "https://charts.longhorn.io";
      chart = "longhorn";
      version = "1.12.0";
      sha256 = "sha256-42GDSNepI7dkqyuVVh8DPwlUqcTEFRMUYg1qz6ZH7/E=";
    };

    values = {
      persistence = {
        defaultClass = false;
        defaultFsType = "xfs";
        defaultClassReplicaCount = 1;
        defaultDataLocality = "best-effort";
        reclaimPolicy = "Retain";
        volumeBindingMode = "Immediate";
        disableRevisionCounter = "true";
        unmapMarkSnapChainRemoved = "enabled";
        backupTargetName = "hetzner";
        recurringJobSelector = {
          enable = true;
          jobList = builtins.toJSON hetznerRecurringJobSelector;
        };
      };

      defaultSettings = {
        defaultReplicaCount = 1;
        replicaSoftAntiAffinity = true;
        allowRecurringJobWhileVolumeDetached = true;
      };
    };
  };
}
