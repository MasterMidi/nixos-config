{ ... }:

{
  fileSystems."/mnt/games" =
    { device = "/dev/disk/by-uuid/6baf0c54-8fb0-425d-ac48-fd2ca868a2bf";
      fsType = "btrfs";
    };

  fileSystems."/mnt/storage" =
  { device = "/dev/disk/by-uuid/b6de6650-e3d2-4efc-a7e4-8dd13473e6a6";
    fsType = "xfs";
  };
}
