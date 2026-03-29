# Inspiration: https://github.com/NixOS/nixpkgs/issues/288037#issuecomment-3424455664

{ ... }:
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
          open = false;
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
}
