{ ... }:
{
  flake.nixosModules.k3s-gpu-nvidia =
    { pkgs, ... }:
    {
      hardware.nvidia = {
        # nvidiaSettings = true;
      };

      services.xserver = {
        videoDrivers = [ "nvidia" ];
      };

      hardware.nvidia-container-toolkit.enable = true;
      hardware.nvidia-container-toolkit.mount-nvidia-executables = true;

      environment.systemPackages = with pkgs; [
        nvidia-container-toolkit
      ];
    };
}
