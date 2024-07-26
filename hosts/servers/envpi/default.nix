{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./blocky
  ];

  # boot.kernelPackages = pkgs.linuxPackages_rpi3;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "envpi"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = false;
  networking.wireless = {
    enable = true;
    networks = {
      "Asus RT-AX86U" = {
        psk = "3zyn2dY&Gp";
      };
    };
  };
  # systemd.services.my-wifi-connection = {
  #   after = ["network.target"];
  #   wantedBy = ["multi-user.target"];
  #   script = ''
  #     wpa_passphrase "Asus RT-AX86U" ${config.age.secrets.wifi-secret.path} | tee /etc/wpa_supplicant.conf > /dev/null
  #     systemctl restart networkmanager
  #   '';
  # };
  # environment.etc."wpa_supplicant.conf".text = lib.readFile "${pkgs.runCommand "wifi setup" {
  #   buildInputs = [pkgs.wpa_supplicant];
  # } "wpa_passphrase \"Asus RT-AX86U\" $(cat ${config.age.secrets.wifi-secret.path}) > $out"}";

  age.secrets.wifi-secret.file = ../../secrets/wifi-secret.age;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  nix.settings.experimental-features = ["nix-command" "flakes"];

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.pi = {
    isNormalUser = true;
    description = "Raspberry Pi 3B v1.2";
    extraGroups = ["networkmanager" "wheel" "i2c"];
    hashedPassword = "$y$j9T$gGYH3.06eDEcKfalPhHPb.$ioKMb3Nw3jtFPvlrYpwkaH7HR4V2.o5mHgq.b9lmx30";
  };
  users.users.root = {
    hashedPassword = "$y$j9T$gGYH3.06eDEcKfalPhHPb.$ioKMb3Nw3jtFPvlrYpwkaH7HR4V2.o5mHgq.b9lmx30";
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true; # set to true if you want the password prompt

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btop
  ];

  # hardware.i2c.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  powerManagement.powertop.enable = false;
  powerManagement.cpuFreqGovernor = "schedutil";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      automation = "!include automations.yaml";
      script = "!include scripts.yaml";
      scene = "!include scenes.yaml";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.home-assistant.configDir}/themes 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
  ];

  networking.firewall.allowedTCPPorts = [
    8123 # home-assitant
  ];

  system.stateVersion = "23.11"; # Did you read the comment?

  lollypops.deployment = {
    local-evaluation = true;
    # Where on the remote the configuration (system flake) is placed
    config-dir = "/etc/nixos";

    # SSH connection parameters
    # ssh.host = "${config.networking.hostName}.local";
    ssh.host = "192.168.50.10";
    ssh.user = "root";
    ssh.command = "ssh";
    ssh.opts = [];

    # sudo options
    sudo.enable = false;
    sudo.command = "sudo";
    sudo.opts = [];
  };
}
