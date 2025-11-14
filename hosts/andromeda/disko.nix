{
  disko.devices = {
    disk = {
      # Existing SDA disk - preserving current layout
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-LITEON_IT_LCS-128L9S_SD0E97882L1TH5110460";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";  # EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      # SDB - SSD with 90% usage and XFS
      ssd = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S3R3NF1JB02862Z";
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "90%";  # Leaving 10% for SSD performance
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/ssd";
              };
            };
          };
        };
      };

      # SDC - HDD with full space usage and XFS
      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZLW1VS5K";
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/hdd";
              };
            };
          };
        };
      };
    };
  };
}
