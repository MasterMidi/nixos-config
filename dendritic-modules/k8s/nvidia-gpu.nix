# Inspiration: https://github.com/NixOS/nixpkgs/issues/288037#issuecomment-3424455664

{ self, ... }:
{
  flake.nixosModules.k3s-gpu-nvidia =
    { pkgs, ... }:
    {
      nixpkgs.config.cudaSupport = true;

      services.xserver.videoDrivers = [ "nvidia" ];

      boot.kernelModules = [
        "nvidia"
        "nvidia_uvm"
        "nvidia_drm"
        "nvidia_modeset"
      ];

      hardware = {
        nvidia = {
          nvidiaPersistenced = true;
          nvidiaSettings = true;
        };

        nvidia-container-toolkit = {
          enable = true;
          mount-nvidia-executables = true;
        };
      };

      environment.systemPackages = with pkgs; [
        nvidia-container-toolkit
      ];

      systemd.services.k3s.path = with pkgs; [
        nvidia-container-toolkit # Provides nvidia-ctk
      ];

      services.k3s.containerdConfigTemplate = ''
        {{ template "base" . }}

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
          privileged_without_host_devices = false
          runtime_engine = ""
          runtime_root = ""
          runtime_type = "io.containerd.runc.v2"
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
          BinaryName = "${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-container-runtime.cdi"
          SystemdCgroup = true
      '';
    };

  flake.nixosModules.k3s-gpu-nvidia-andromeda =
    { config, lib, ... }:
    {
      imports = [ self.nixosModules.k3s-gpu-nvidia ];

      # GeForce 1060 is only supported in the 580.xx legacy driver now....
      # NVRM: The NVIDIA NVIDIA GeForce GTX 1060 6GB GPU installed in this system is
      # NVRM:  supported through the NVIDIA 580.xx Legacy drivers. Please
      # NVRM:  visit http://www.nvidia.com/object/unix.html for more
      # NVRM:  information.  The 595.58.03 NVIDIA driver will ignore
      # NVRM:  this GPU.  Continuing probe...
      hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.legacy_580;

      # Open source kernel module is only supported for Turing and later: https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      hardware.nvidia.open = false;
    };
}
