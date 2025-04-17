{pkgs, ...}: {
  hardware.enableRedistributableFirmware = true;
  # Firmware updates - fwupd
  services.fwupd.enable = true;
  # Allow fwupd-refresh to restart if failed (after resume)
  systemd.services.fwupd-refresh = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "20";
    };
    unitConfig = {
      StartLimitIntervalSec = 100;
      StartLimitBurst = 5;
    };
  };

  # Set default shell to dash instead of bash
  # environment.binsh = "${pkgs.dash}/bin/dash";

  # Set time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";
}
