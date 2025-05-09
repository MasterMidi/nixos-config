{pkgs, ...}: {
  # inital Nixos version
  system.stateVersion = "23.05";

  # Set kernel package
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 5;
    };
  };

  boot.plymouth = {
    enable = true;
    logo = pkgs.fetchurl {
      url = "https://nixos.org/logo/nixos-hires.png";
      sha256 = "1ivzgd7iz0i06y36p8m5w48fd8pjqwxhdaavc0pxs7w1g7mcy5si";
    };
    # theme = "breeze";
    theme = "angular_alt";
    themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["angular_alt"];})];
  };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Power management
  powerManagement.cpuFreqGovernor = "schedutil";
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "Powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
}
