{...}:
{
  jovian = {
    hardware = {
      has.amd.gpu = false;
    #   amd.gpu.enableBacklightControl = false;
    };
    steam = {
      enable = true;
      updater.splash = "steamos";
      autoStart = false;
      user = "michael";
      desktopSession = "plasma";
    };
    steamos = {
      useSteamOSConfig = true;
    };
  };
}