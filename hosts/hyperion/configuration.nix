{ ... }:
{
  networking.hostName = "hyperion";

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      prompt.enable = true;
    };
    lazygit.enable = true;
  };

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
    wslConf.network.generateResolvConf = false;
    defaultUser = "michael";
    startMenuLaunchers = true;
  };

  services.resolved.enable = true;

  system.stateVersion = "25.05";
}
