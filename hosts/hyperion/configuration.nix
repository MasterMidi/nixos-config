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

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;
  };

  services.resolved.enable = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  system.stateVersion = "25.05";
}
