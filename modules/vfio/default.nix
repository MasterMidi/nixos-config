{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.virtualisation.vfio;

  # AMD Radeon RX 7800 XT
  gpuIDs = [
    "1002:747e" # Graphics
    "1002:ab30" # Audio
  ];
in {
  imports = [
    ./kvmfr-options.nix
  ];

  options.virtualisation.vfio = {
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
        "kvm_amd"
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        "amd"
      ];

      kernelParams =
        [
          # enable IOMMU
          "amd_iommu=on"
          "iommu=pt"
          # "video=efifb:off"
          "kvm.ignore_msrs=1"
          "vfio-pci.disable_idle_d3=1"
        ]
        ++ lib.optional cfg.enable
        # isolate the GPU
        ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
    };

    hardware.opengl.enable = lib.mkForce true;
    virtualisation.spiceUSBRedirection.enable = lib.mkDefault true;

    # Enable the virtualisation services
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      # extraConfig = ''
      #   unix_sock_group = "libvirtd"
      #   unix_sock_rw_perms = "0770"
      # '';
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = with pkgs; [OVMFFull.fd];
        # verbatimConfig = ''
        #   log_filters="1:qemu"
        #   log_outputs="1:file:/var/log/libvirt/libvirtd.log"
        # '';
      };
      # hooks.qemu = {
      #   win11-prepare-begin = pkgs.writeShellScript "start" ''
      #     # Helpful to read output when debugging
      #     set -x

      #     # Load variables we defined
      #     source "/var/lib/libvirt/hooks/kvm.conf"

      #     # Kill main dGPU display
      #     # ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-2, disable"
      #     # ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-3, 3440x1440@144, 1920x0, 1"
      #     ${pkgs.hyprland}/bin/hyprctl dispatch exit 0
      #     systemctl stop display-manager
      #     systemctl isolate multi-user.target
      #     while systemctl is-active --quiet "display-manager"; do
      #       sleep "1"
      #     done

      #     # Unbind VTconsoles
      #     echo 0 > /sys/class/vtconsole/vtcon0/bind
      #     echo 0 > /sys/class/vtconsole/vtcon1/bind

      #     # Unbind EFI-Framebuffer
      #     echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

      #     # Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
      #     sleep 2

      #     modprobe -r drm_kms_helper
      #     modprobe -r amdgpu
      #     modprobe -r radeon
      #     modprobe -r drm

      #     # Unbind the GPU from display driver
      #     virsh nodedev-detach $VIRSH_GPU_VIDEO
      #     virsh nodedev-detach $VIRSH_GPU_AUDIO

      #     # Load VFIO Kernel Module
      #     modprobe vfio
      #     modprobe vfio_pci
      #     modprobe vfio_iommu_type1

      #     systemctl start display-manager
      #   '';
      #   win11-release-end = pkgs.writeShellScript "revert" ''
      #     set -x

      #     # Load variables we defined
      #     source "/var/lib/libvirt/hooks/kvm.conf"

      #     systemctl stop display-manager
      #     systemctl isolate multi-user.target
      #     while systemctl is-active --quiet "display-manager"; do
      #       sleep "1"
      #     done

      #     # Unload vfio module
      #     modprobe -r vfio_pci
      #     modprobe -r vfio_iommu_type1
      #     modprobe -r vfio

      #     # Re-Bind GPU
      #     virsh nodedev-reattach $VIRSH_GPU_VIDEO
      #     virsh nodedev-reattach $VIRSH_GPU_AUDIO
      #     modprobe drm
      #     modprobe amdgpu
      #     modprobe radeon
      #     modprobe drm_kms_helper

      #     # Bind EFI Framebuffer
      #     echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

      #     # Rebind VT consoles
      #     echo 1 > /sys/class/vtconsole/vtcon0/bind
      #     echo 1 > /sys/class/vtconsole/vtcon1/bind

      #     # Restart Display Manager
      #     systemctl start display-manager.service

      #     ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-3, disable"
      #     ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-2, 3440x1440@144, 1920x0, 1"
      #   '';
      # };
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
      libvirt-glib
      libguestfs
      gnome.adwaita-icon-theme
      looking-glass-client
    ];

    systemd.services.libvirtd = {
      path = let
        env = pkgs.buildEnv {
          name = "qemu-hook-env";
          paths = with pkgs; [
            bash
            libvirt
            kmod
            systemd
            ripgrep
            sd
          ];
        };
      in [env];
    };

    systemd.tmpfiles.rules = [
      "L+ /var/lib/libvirt/vbios/rx7800xt-gb.rom - - - - ${./rx7800xt-gb.rom}" # vbios for the gpu
      # "L+ /var/lib/libvirt/hooks/qemu - - - - ${pkgs.writeShellScript "hook" (builtins.readFile ./scripts/qemu_hook.sh)}" # hook script to enable running script for vms
      # "L+ /var/lib/libvirt/hooks/kvm.conf - - - - ${./scripts/kvm.conf}" # hook script to enable running script for vms
      # "L+ /var/lib/libvirt/hooks/qemu.d/win11/prepare/begin/start.sh - - - - ${pkgs.writeShellScript "start" ''
      #   # Helpful to read output when debugging
      #   set -x

      #   # Load variables we defined
      #   source "/var/lib/libvirt/hooks/kvm.conf"

      #   # Kill main dGPU display
      #   ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-2, disable"
      #   ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-3, 3440x1440@144, 1920x0, 1"

      #   # Unbind VTconsoles
      #   echo 0 > /sys/class/vtconsole/vtcon0/bind
      #   echo 0 > /sys/class/vtconsole/vtcon1/bind

      #   # Unbind EFI-Framebuffer
      #   echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

      #   # Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
      #   sleep 2

      #   # Unbind the GPU from display driver
      #   virsh nodedev-detach $VIRSH_GPU_VIDEO
      #   virsh nodedev-detach $VIRSH_GPU_AUDIO

      #   # Load VFIO Kernel Module
      #   modprobe vfio
      #   modprobe vfio_pci
      #   modprobe vfio_iommu_type1
      # ''}" # begin script for win11 vm
      # "L+ /var/lib/libvirt/hooks/qemu.d/win11/release/end/revert.sh - - - - ${pkgs.writeShellScript "revert" ''
      #   set -x

      #   # Load variables we defined
      #   source "/var/lib/libvirt/hooks/kvm.conf"

      #   # Unload vfio module
      #   modprobe -r vfio
      #   modprobe -r vfio_pci
      #   modprobe -r vfio_iommu_type1

      #   # Re-Bind GPU
      #   virsh nodedev-reattach $VIRSH_GPU_VIDEO
      #   virsh nodedev-reattach $VIRSH_GPU_AUDIO

      #   # Bind EFI Framebuffer
      #   echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

      #   # Rebind VT consoles
      #   echo 1 > /sys/class/vtconsole/vtcon0/bind
      #   echo 1 > /sys/class/vtconsole/vtcon1/bind

      #   # Restart Display Manager
      #   # systemctl start display-manager.service

      #   ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-3, disable"
      #   ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-2, 3440x1440@144, 1920x0, 1"
      # ''}" # end script for win11 vm
    ];
  };
}
