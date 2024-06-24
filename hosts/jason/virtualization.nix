{...}: {
  # Enable the KVM hypervisor
  boot.kernelModules = ["kvm-amd"];
  boot.extraModprobeConfig = "options kvm_amd nested=1";

  # Enable the libvirt service
  virtualisation.libvirtd.enable = true;
  users.users.michael.extraGroups = ["libvirtd"];

  # Add the virt-manager program
  programs.virt-manager.enable = true;
}
