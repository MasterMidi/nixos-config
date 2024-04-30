{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.vfio;

  # AMD Radeon RX 7800 XT
  gpuIDs = [
    "1002:747e" # Graphics
    "1002:ab30" # Audio
  ];
in {
  options.vfio = {
    enable = lib.mkEnableOption "Configure the machine for VFIO";
    gpuIDs = lib.mkOption {
      type = lib.types.list lib.types.string;
      default = gpuIDs;
      description = "List of GPU IDs to isolate";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"

        "amd"
      ];

      kernelParams = [
        # enable IOMMU
        "amd_iommu=on"
      ];
      # ++ lib.optional cfg.enable
      # # isolate the GPU
      # ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
    };

    hardware.opengl.enable = lib.mkForce true;
    virtualisation.spiceUSBRedirection.enable = lib.mkDefault true;

    # Enable the virtualisation services
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = with pkgs; [OVMFFull.fd];
      };
    };
    programs.virt-manager.enable = true;
    services.spice-vdagentd.enable = true;
    environment.systemPackages = with pkgs; [
      win-virtio
      win-spice
      spice-protocol
      spice
      spice-gtk
      virt-viewer
      gnome.adwaita-icon-theme
    ];
  };
}
