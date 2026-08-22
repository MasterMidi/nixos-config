{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HBJQ-000L2_S4DYNX1R303730";
      content = {
        type = "gpt";
        partitions = {
          efi = {
            label = "efi";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0022"
                "dmask=0022"
              ];
            };
          };
          primary = {
            label = "primary";
            size = "419G";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/";
              extraArgs = [
                "-L"
                "nixos"
              ];
            };
          };
          swap = {
            label = "swap";
            size = "16G";
            content = {
              type = "swap";
              discardPolicy = "both";
              extraArgs = [
                "-L"
                "swap"
              ];
            };
          };
        };
      };
    };
  };
}
