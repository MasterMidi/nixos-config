{pkgs,...}:let
  script = pkgs.writeShellScript "mergerfs-select-disk" ''
# Get the file mimetype
mimetype=$(${pkgs.file}/bin/file --mime-type -b "$1")

# Check if it's a video file
case $mimetype in
    video/*)
        echo "/mnt/hdd"
        ;;
    *)
        echo "/mnt/ssd"
        ;;
esac
    '';
in {
  environment.systemPackages = with pkgs; [
    mergerfs # add mmergerfs support
  ];

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/2acaf814-d46b-45a6-a679-c0bf467a2457";
    fsType = "xfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/9d66d39f-6f56-4d40-a768-0773e4db01b3";
    fsType = "xfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/pool" = {
    device = "/mnt/hdd:/mnt/ssd";
    fsType = "fuse.mergerfs";
    options = [
      "defaults"
      "nonempty"
      "allow_other"
      "inodecalc=hybrid-hash"
      "cache.files=off"
      "moveonenospc=true"
      "dropcacheonclose=true"
      "minfreespace=10G"
      "fsname=mergerfs"

      "policy=custom:${script}"
      "category.create=custom"
    ];
  };
}

