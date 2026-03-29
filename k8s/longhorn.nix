{ pkgs, ... }:
{
  kubernetes.resources.longhorn-system = {
    StorageClass.longhorn = {
      metadata.annotations.storageclass."kubernetes.io/is-default-class" = true;
      provisioner = "driver.longhorn.io";
      allowVolumeExpansion = true;
      reclaimPolicy = "Retain";
      volumeBindingMode = "Immediate";
      parameters = {
        numberOfReplicas = "1";
        dataLocality = "best-effort";
        fsType = "xfs";
        staleReplicaTimeout = "30";
        disableRevisionCounter = "true";
        unmapMarkSnapChainRemoved = "ignored";
      };
    };

    StorageClass.longhorn-static = {
      metadata.annotations.storageclass."kubernetes.io/is-default-class" = true;
      provisioner = "driver.longhorn.io";
      allowVolumeExpansion = true;
      reclaimPolicy = "Delete";
      volumeBindingMode = "Immediate";
      parameters = {
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
  helm.releases.longhorn = {
    namespace = "longhorn-system";
    chart = pkgs.fetchHelm {
      repo = "https://charts.longhorn.io";
      chart = "longhorn";
      version = "1.11.0";
      sha256 = "sha256-s1UBZTlU/AW6ZQmqN9wiQOA76uoWgCBGhenn9Hx3DCQ=";
    };

    values = {
      defaultSettings = {
        defaultReplicaCount = 1;
        replicaSoftAntiAffinity = true;
      };
    };
  };
}
