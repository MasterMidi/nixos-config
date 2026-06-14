{ pkgs, config, ... }:
{
  kubernetes.resources.longhorn-system = {
    StorageClass.longhorn-static = {
      metadata.annotations.storageclass."kubernetes.io/is-default-class" = false;
      provisioner = "driver.longhorn.io";
      allowVolumeExpansion = true;
      reclaimPolicy = "Delete";
      volumeBindingMode = "Immediate";
      parameters = {
        numberOfReplicas = "1";
        backupTargetName = "hetzner";
        dataLocality = "best-effort";
        fsType = "xfs";
        staleReplicaTimeout = "30";
      };
    };

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
        # fromBackup = "";
        diskSelector = "ssd,fast";
        # mkfsParams = "-I 256 -b 4096 -O ^metadata_csum,^64bit";
        # backingImage = "bi-test";
        # backingImageDataSourceType = "download";
        # backingImageDataSourceParameters = "{\"url\": \"https://backing-image-example.s3-region.amazonaws.com/test-backing-image\"}";
        # backingImageChecksum = "SHA512 checksum of the backing image";
        # unmapMarkSnapChainRemoved = "ignored";
        # nodeSelector = "storage,fast";
        # recurringJobSelector = "[{\"name\":\"snap-group\", \"isGroup\":true}, {\"name\":\"backup\", \"isGroup\":false}]";
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
        cron = "0 3 * * *";
        task = "backup";
        groups = [ "hetzner-backup" ];
        retain = 7;
        concurrency = 1;
        parameters.full-backup-interval = "7";
      };
    };
  };

  helm.releases.longhorn = {
    namespace = "longhorn-system";
    chart = pkgs.fetchHelm {
      repo = "https://charts.longhorn.io";
      chart = "longhorn";
      version = "1.11.2";
      sha256 = "sha256-5a2Kr2xSscWCP0fP+0zB1OCtY463tcTzgZNkoY5Mj1Y=";
    };

    values = {
      persistence = {
        defaultClass = true;
        defaultFsType = "xfs";
        defaultClassReplicaCount = 1;
        defaultDataLocality = "best-effort";
        reclaimPolicy = "Retain";
        volumeBindingMode = "Immediate";
        disableRevisionCounter = "true";
        unmapMarkSnapChainRemoved = "ignored";
        backupTargetName = "hetzner";
      };

      defaultSettings = {
        defaultReplicaCount = 1;
        replicaSoftAntiAffinity = true;
        allowRecurringJobWhileVolumeDetached = true;
      };
    };
  };
}
