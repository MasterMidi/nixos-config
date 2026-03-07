# Helpful to read output when debugging
set -x

# Load variables we defined
source "/var/lib/libvirt/hooks/kvm.conf"

# Stop display manager
# systemctl stop display-manager.service
## Uncomment the following line if you use GDM
#killall gdm-x-session
# Kill main dGPU display
hyprctl keyword monitor "DP-2, disable"
hyprctl keyword monitor "DP-3, 3440x1440@144, 1920x0, 1"

# # Unbind VTconsoles
# echo 0 >/sys/class/vtconsole/vtcon0/bind
# echo 0 >/sys/class/vtconsole/vtcon1/bind

# # Unbind EFI-Framebuffer
# echo efi-framebuffer.0 >/sys/bus/platform/drivers/efi-framebuffer/unbind

# # Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
# sleep 2

# # Unbind the GPU from display driver
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO

# # Load VFIO Kernel Module
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1
