set -x

# Load variables we defined
source "/var/lib/libvirt/hooks/kvm.conf"

# Re-Bind GPU
virsh nodedev-reattach $VIRSH_GPU_VIDEO
virsh nodedev-reattach $VIRSH_GPU_AUDIO

# Reload nvidia modules
# modprobe nvidia
# modprobe nvidia_modeset
# modprobe nvidia_uvm
# modprobe nvidia_drm

# Rebind VT consoles
# echo 1 >/sys/class/vtconsole/vtcon0/bind
# Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
#echo 1 > /sys/class/vtconsole/vtcon1/bind

# nvidia-xconfig --query-gpu-info >/dev/null 2>&1
# echo "efi-framebuffer.0" >/sys/bus/platform/drivers/efi-framebuffer/bind

# Restart Display Manager
# systemctl start display-manager.service

hyprctl keyword monitor "DP-3, disable"
hyprctl keyword monitor "DP-2, 3440x1440@144, 1920x0, 1"
